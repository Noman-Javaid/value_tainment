# frozen_string_literal: true

class Individual::Calls::DeclineReschedulingRequest
  prepend SimpleCommand

  attr_accessor :individual, :expert_call, :rescheduling_request

  def initialize(individual, expert_call, rescheduling_request)
    @individual = individual
    @expert_call = expert_call
    @rescheduling_request = rescheduling_request
  end

  def call
    (errors.add :error_message, I18n.t('api.expert_call.rescheduling.errors.invalid_access')).then { return } if expert_call.individual != individual && rescheduling_request.rescheduled_by == individual
    # validate if the call is reschedulable
    (errors.add :error_message, I18n.t('api.expert_call.rescheduling.accept.invalid_access')).then { return } unless expert_call.rescheduling_request == rescheduling_request
    # reschedule the expert call.
    time_left = (Time.parse(expert_call.scheduled_time_start.to_s) - Time.parse(Time.zone.now.to_s)) / 3600
    if time_left <= 24
      # request has expired
      rescheduling_request.expired!
      rescheduling_request.expert_call.update(call_status: 'scheduled')
      (errors.add :error_message, I18n.t('api.expert_call.rescheduling.accept.invalid_time')).then { return }
    else
      # set the new time for the call
      begin
        ActiveRecord::Base.transaction do
          rescheduling_request.declined!
          expert_call.update(call_status: 'scheduled')

          # send declined notification to expert
          Notifications::Experts::ExpertCallNotifier.new(expert_call).rescheduling_request_declined

          # send sms to expert
          individual_user = individual.user
          expert_user = expert_call.expert.user
          # send sms to individual
          expert_sms = I18n.t('api.expert_call.rescheduling.decline.message_to_expert',
                              individual_name: individual_user.name,
                              expert_name: expert_user.name,
                              call_date_time: Time.parse(expert_call.new_requested_start_time.to_s).in_time_zone(individual_user.timezone).strftime("%B %d, %Y at %-I:%M %p"))
          TwilioServices::SendUpdateBySms.call(expert_user, expert_sms, I18n.t('global.events.reschedule_request_declined')) if expert_user.phone_number.present?
          # send email to expert
          CallReschedulingMailer.declined_by_individual(expert_call).deliver_later

          # cancel the call if individual is declining.
          Expert::Calls::Cancel.call(expert_call.expert, expert_call, I18n.t('api.expert_call.cancellation.cancel_on_declining_rescheduling_request'))
        end
      rescue StandardError => e
        errors.add :error_message, e.message
        Rails.logger.error(individual_id: individual.id,
                           expert_call_id: expert_call.id,
                           rescheduling_request_id: rescheduling_request.id,
                           message: e.message)
      end
    end

  end
end
