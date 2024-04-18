# frozen_string_literal: true

class Individual::Calls::Reschedule
  prepend SimpleCommand

  attr_accessor :individual, :expert_call, :rescheduling_params

  def initialize(individual, expert_call, rescheduling_params = nil)
    @individual = individual
    @expert_call = expert_call
    @rescheduling_params = rescheduling_params
  end

  def call
    (errors.add :error_message, I18n.t('api.expert_call.rescheduling.errors.invalid_access')).then { return } unless expert_call.individual == individual
    # validate if the call is reschedulable
    (errors.add :error_message, I18n.t('api.expert_call.rescheduling.errors.invalid_status')).then { return } unless expert_call.reschedulable?
    # reschedule the expert call.
    (errors.add :error_message, I18n.t('api.expert_call.rescheduling.errors.invalid_time')).then { return } if Time.zone.parse(rescheduling_params[:new_requested_start_time].to_s) <= Time.zone.now
    begin
      ActiveRecord::Base.transaction do
        reschedule_request = ReschedulingRequest.create(rescheduled_by: individual,
                                                        rescheduling_reason: rescheduling_params[:rescheduling_reason],
                                                        new_requested_start_time: rescheduling_params[:new_requested_start_time])
        expert_call.rescheduling_requests << reschedule_request
        expert_call.save!
        expert_call.set_as_requires_reschedule_confirmation!

        # send cancellation notification to individual
        Notifications::Experts::ExpertCallNotifier.new(expert_call).rescheduled_call

        # send sms to expert
        individual_user = individual.user
        expert_user = expert_call.expert.user
        # send sms to expert
        expert_sms = I18n.t('api.expert_call.rescheduling.message_to_expert',
                                individual_name: individual_user.name,
                                expert_name: expert_user.name,
                                call_date_time: Time.parse(expert_call.new_requested_start_time.to_s).in_time_zone(expert_user.timezone).strftime("%B %d, %Y at %-I:%M %p"))
        TwilioServices::SendUpdateBySms.call(expert_user, expert_sms, I18n.t('global.events.reschedule_request')) if expert_user.phone_number.present?
        # send email to expert
        CallReschedulingMailer.send_to_expert(expert_call).deliver_later
      end
    rescue StandardError => e
      errors.add :error_message, e.message
      Rails.logger.error(individual_id: individual.id,
                         expert_call_id: expert_call.id,
                         rescheduling_params_reason: rescheduling_params,
                         message: e.message)
    end
  end
end
