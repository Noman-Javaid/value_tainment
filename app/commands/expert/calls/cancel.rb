# frozen_string_literal: true

class Expert::Calls::Cancel
  prepend SimpleCommand

  attr_accessor :expert, :expert_call, :cancellation_reason

  def initialize(expert, expert_call, cancellation_reason = nil)
    @expert = expert
    @expert_call = expert_call
    @cancellation_reason = cancellation_reason
  end

  def call
    (errors.add :error_message, I18n.t('api.expert_call.cancellation.errors.invalid_access')).then { return } unless expert_call.expert == expert
    # validate if the call is cancellable
    (errors.add :error_message, I18n.t('api.expert_call.cancellation.errors.invalid_status')).then { return } unless expert_call.cancellable?(expert)
    # cancel the expert call.
    begin
      ActiveRecord::Base.transaction do
        expert_call.update(cancellation_reason: cancellation_reason, cancelled_at: Time.zone.now, cancelled_by: expert)
        expert_call.cancel! # this will trigger the refund automatically.

        # send cancellation notification to individual
        Notifications::Individuals::ExpertCallNotifier.new(expert_call).cancelled_call

        # send sms to individual and expert
        individual_user = expert_call.individual.user
        expert_user = expert.user
        # send sms to individual
        individual_sms = I18n.t('api.expert_call.cancellation.message_to_individual',
                                individual_name: individual_user.name,
                                expert_name: expert_user.name,
                                call_date_time: Time.parse(expert_call.scheduled_time_start.to_s).in_time_zone(individual_user.timezone).strftime("%B %d, %Y at %-I:%M %p"))
        TwilioServices::SendUpdateBySms.call(individual_user, individual_sms, I18n.t('global.events.call_cancellation')) if individual_user.phone_number.present?

        # send sms to expert
        expert_sms = I18n.t('api.expert_call.cancellation.message_to_expert',
                            expert_name: expert_user.name,
                            individual_name: individual_user.name,
                            call_date_time: Time.parse(expert_call.scheduled_time_start.to_s).in_time_zone(expert_user.timezone).strftime("%B %d, %Y at %-I:%M %p"))
        TwilioServices::SendUpdateBySms.call(expert_user, expert_sms, I18n.t('global.events.call_cancellation')) if expert_user.phone_number.present?

        # send email to individual and expert
        CallCancellationMailer.send_to_individual(expert_call).deliver_later
        CallCancellationMailer.send_to_expert(expert_call).deliver_later
      end
    rescue => e
      errors.add :error_message, e.message
      Rails.logger.error(expert_id: expert.id,
                         expert_call_id: expert_call.id,
                         cancellation_reason: cancellation_reason,
                         message: e.message)
    end
  end
end
