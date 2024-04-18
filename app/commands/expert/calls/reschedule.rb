# frozen_string_literal: true

class Expert::Calls::Reschedule
  prepend SimpleCommand

  attr_accessor :expert, :expert_call, :rescheduling_params

  def initialize(expert, expert_call, rescheduling_params = nil)
    @expert = expert
    @expert_call = expert_call
    @rescheduling_params = rescheduling_params
  end

  def call
    (errors.add :error_message, I18n.t('api.expert_call.rescheduling.errors.invalid_access')).then { return } unless expert_call.expert == expert
    # validate if the call is reschedulable
    (errors.add :error_message, I18n.t('api.expert_call.rescheduling.errors.invalid_status')).then { return } unless expert_call.reschedulable?
    (errors.add :error_message, I18n.t('api.expert_call.rescheduling.errors.invalid_time')).then { return } if Time.zone.parse(rescheduling_params[:new_requested_start_time].to_s) <= Time.zone.now

    # reschedule the expert call.
    begin
      ActiveRecord::Base.transaction do
        reschedule_request = ReschedulingRequest.create(rescheduled_by: expert,
                                                        rescheduling_reason: rescheduling_params[:rescheduling_reason],
                                                        new_requested_start_time: rescheduling_params[:new_requested_start_time])
        expert_call.rescheduling_requests << reschedule_request
        expert_call.save!
        expert_call.set_as_requires_reschedule_confirmation!

        # send cancellation notification to individual
        Notifications::Individuals::ExpertCallNotifier.new(expert_call).rescheduled_call

        # send sms to individual and expert
        individual_user = expert_call.individual.user
        expert_user = expert.user
        # send sms to individual
        individual_sms = I18n.t('api.expert_call.rescheduling.message_to_individual',
                                individual_name: individual_user.name,
                                expert_name: expert_user.name,
                                call_date_time: Time.parse(expert_call.new_requested_start_time.to_s).in_time_zone(individual_user.timezone).strftime("%B %d, %Y at %-I:%M %p"))
        TwilioServices::SendUpdateBySms.call(individual_user, individual_sms, I18n.t('global.events.reschedule_request')) if individual_user.phone_number.present?
        # send email to individual and expert
        CallReschedulingMailer.send_to_individual(expert_call).deliver_later
      end
    rescue StandardError => e
      errors.add :error_message, e.message
      Rails.logger.error(expert_id: expert.id,
                         expert_call_id: expert_call.id,
                         rescheduling_params_reason: rescheduling_params,
                         message: e.message)
    end
  end
end
