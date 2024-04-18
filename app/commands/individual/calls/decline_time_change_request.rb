# frozen_string_literal: true

class Individual::Calls::DeclineTimeChangeRequest
  prepend SimpleCommand

  attr_accessor :individual, :expert_call, :time_change_request

  def initialize(individual, expert_call, time_change_request)
    @individual = individual
    @expert_call = expert_call
    @time_change_request = time_change_request
  end

  def call
    (errors.add :error_message, I18n.t('api.expert_call.change_time.errors.invalid_access')).then { return } if expert_call.individual != individual
    (errors.add :error_message, I18n.t('api.expert_call.change_time.errors.invalid_access')).then { return } unless expert_call.time_change_request == time_change_request
    time_left = (Time.parse(expert_call.scheduled_time_start.to_s) - Time.parse(Time.zone.now.to_s)) / 3600
    if time_left <= 24
      # request has expired
      time_change_request.expired!
      time_change_request.expert_call.update(call_status: 'scheduled')
      (errors.add :error_message, I18n.t('api.expert_call.change_time.errors.invalid_time')).then { return }
    else
      # set the new time for the call
      begin
        ActiveRecord::Base.transaction do
          time_change_request.declined!
          # send declined notification to expert
          #Notifications::Experts::ExpertCallNotifier.new(expert_call).time_change_request_declined
          # send sms to expert
          individual_user = individual.user
          expert_user = expert_call.expert.user
          # send sms to individual
          expert_sms = I18n.t('api.expert_call.change_time.decline.message_to_expert',
                              individual_name: individual_user.name,
                              expert_name: expert_user.name,
                              call_date_time: Time.parse(time_change_request.new_suggested_start_time.to_s).in_time_zone(individual_user.timezone).strftime("%B %d, %Y at %-I:%M %p"))
          TwilioServices::SendUpdateBySms.call(expert_user, expert_sms, I18n.t('global.events.time_change_request_declined')) if expert_user.phone_number.present?
          # send email to expert
          CallTimeChangeRequestMailer.declined_by_individual(expert_call).deliver_later

          expert_call.decline!
          Notifications::Individuals::ExpertCallNotifier.new(expert_call).rejected_call
        end
      rescue StandardError => e
        errors.add :error_message, e.message
        Rails.logger.error(individual_id: individual.id,
                           expert_call_id: expert_call.id,
                           time_change_request_id: time_change_request.id,
                           message: e.message)
      end
    end

  end
end
