# frozen_string_literal: true

class Individual::Calls::AcceptReschedulingRequest
  prepend SimpleCommand

  attr_accessor :individual, :expert_call, :rescheduling_request

  def initialize(individual, expert_call, rescheduling_request)
    @individual = individual
    @expert_call = expert_call
    @rescheduling_request = rescheduling_request
  end

  def call
    (errors.add :error_message, I18n.t('api.expert_call.rescheduling.errors.invalid_access')).then { return } if expert_call.individual != individual && rescheduling_request.rescheduled_by == individual
    (errors.add :error_message, I18n.t('api.expert_call.rescheduling.accept.invalid_access')).then { return } unless expert_call.rescheduling_request == rescheduling_request
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
          rescheduling_request.accepted!
          expert_call.reschedule_call!(rescheduling_request.new_requested_start_time)
          expert_call.update(call_status: 'scheduled')

          # send acceptance notification to expert
          Notifications::Experts::ExpertCallNotifier.new(expert_call).rescheduling_request_accepted

          individual_user = individual.user
          expert_user = expert_call.expert.user
          # send sms to expert
          expert_sms = I18n.t('api.expert_call.rescheduling.accept.message_to_expert',
                                  individual_name: individual_user.name,
                                  expert_name: expert_user.name,
                                  call_date_time: Time.parse(expert_call.new_requested_start_time.to_s).in_time_zone(expert_user.timezone).strftime("%B %d, %Y at %-I:%M %p"))
          TwilioServices::SendUpdateBySms.call(expert_user, expert_sms, I18n.t('global.events.reschedule_request_accepted')) if expert_user.phone_number.present?
          # send email to individual and expert
          CallReschedulingMailer.accepted_by_individual(expert_call).deliver_later
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
