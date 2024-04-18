# frozen_string_literal: true

class Expert::Calls::RequestTimeChange
  prepend SimpleCommand

  attr_accessor :expert, :expert_call, :time_change_request_params

  def initialize(expert, expert_call, time_change_request_params = nil)
    @expert = expert
    @expert_call = expert_call
    @time_change_request_params = time_change_request_params
  end

  def call
    (errors.add :error_message, I18n.t('api.expert_call.change_time.errors.invalid_access')).then { return } unless expert_call.expert == expert
    # validate if the time change is allowed
    (errors.add :error_message, I18n.t('api.expert_call.change_time.errors.invalid_status')).then { return } unless expert_call.time_change_allowed?
    (errors.add :error_message, I18n.t('api.expert_call.change_time.errors.invalid_time')).then { return } if Time.zone.parse(time_change_request_params[:new_suggested_start_time].to_s) <= Time.zone.now

    # reschedule the expert call.
    begin
      ActiveRecord::Base.transaction do
        time_change_request = TimeChangeRequest.create(requested_by: expert,
                                                       reason: time_change_request_params[:reason],
                                                       new_suggested_start_time: time_change_request_params[:new_suggested_start_time])
        expert_call.time_change_requests << time_change_request
        expert_call.save!
        expert_call.set_as_requires_time_change_confirmation!

        # send notification to individual
        Notifications::Individuals::ExpertCallNotifier.new(expert_call).time_change_request

        # send sms to individual and expert
        individual_user = expert_call.individual.user
        expert_user = expert.user
        # send sms to individual
        individual_sms = I18n.t('api.expert_call.change_time.message_to_individual',
                                individual_name: individual_user.name,
                                expert_name: expert_user.name,
                                call_date_time: Time.parse(expert_call.new_requested_start_time.to_s).in_time_zone(individual_user.timezone).strftime("%B %d, %Y at %-I:%M %p"))
        TwilioServices::SendUpdateBySms.call(individual_user, individual_sms, I18n.t('global.events.time_change_request')) if individual_user.phone_number.present?
        # send email to individual and expert
        CallTimeChangeRequestMailer.send_to_individual(expert_call).deliver_later
      end
    rescue StandardError => e
      errors.add :error_message, e.message
      Rails.logger.error(expert_id: expert.id,
                         expert_call_id: expert_call.id,
                         time_change_request_params: time_change_request_params,
                         message: e.message)
    end
  end
end
