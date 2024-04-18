# frozen_string_literal: true

class Expert::Calls::AcceptReschedulingRequest
  prepend SimpleCommand

  attr_accessor :expert, :expert_call, :rescheduling_request

  def initialize(expert, expert_call, rescheduling_request)
    @expert = expert
    @expert_call = expert_call
    @rescheduling_request = rescheduling_request
  end

  def call
    (errors.add :error_message, I18n.t('api.expert_call.rescheduling.errors.invalid_access')).then { return } if expert_call.expert != expert || rescheduling_request.rescheduled_by == expert
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
          rescheduling_request.accepted!
          expert_call.reschedule_call!(rescheduling_request.new_requested_start_time)
          expert_call.update(call_status: 'scheduled')

          # send acceptance notification to individual
          Notifications::Individuals::ExpertCallNotifier.new(expert_call).rescheduling_request_accepted

          # send sms to individual
          individual_user = expert_call.individual.user
          expert_user = expert.user
          # send sms to individual
          individual_sms = I18n.t('api.expert_call.rescheduling.accept.message_to_individual',
                                  individual_name: individual_user.name,
                                  expert_name: expert_user.name,
                                  call_date_time: Time.parse(expert_call.new_requested_start_time.to_s).in_time_zone(individual_user.timezone).strftime("%B %d, %Y at %-I:%M %p"))
          TwilioServices::SendUpdateBySms.call(individual_user, individual_sms, I18n.t('global.events.reschedule_request_accepted')) if individual_user.phone_number.present?
          # send email to individual and expert
          CallReschedulingMailer.accepted_by_expert(expert_call).deliver_later
        end
      rescue StandardError => e
        errors.add :error_message, e.message
        Rails.logger.error(expert_id: expert.id,
                           expert_call_id: expert_call.id,
                           rescheduling_request_id: rescheduling_request.id,
                           message: e.message)
      end
    end

  end
end
