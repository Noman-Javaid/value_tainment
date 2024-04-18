class Api::V1::Expert::ExpertCalls::ConfirmScheduleController <
      Api::V1::Expert::ExpertCallsController
  before_action :set_expert_call, only: %i[update]

  def update
    case confirm_schedule_params[:call_status]
    when 'declined'
      @expert_call.decline!
      Notifications::Individuals::ExpertCallNotifier.new(@expert_call).rejected_call
    when 'scheduled'
      unless @expert_call.available_to_scheduled?
        return json_error_response(
          'This time slot is no longer available. You can decline the call or suggest a new time for the user.', :unprocessable_entity
        )
      end

      @expert_call.schedule!
      # job to create room 1 minute before schedule time start
      ExpertCalls::CreateExpertCallJob.set(
        wait_until: 1.minute.ago(@expert_call.scheduled_time_start)
      ).perform_later(@expert_call.id)

      # service to send push notification to expert call about to start
      Notifications::Experts::ExpertCallNotifier.new(@expert_call).about_to_start

      notifier = Notifications::Individuals::ExpertCallNotifier.new(@expert_call)
      # service to send push notification to individual call confirmed
      notifier.confirmed_call
      # service to send push notification to individual call about to start
      notifier.about_to_start
      # service to send push notification according to reminders
      Notifications::UpcomingEventReminderNotifier.new(@expert_call).execute
    else
      json_error_response(
        'Invalid parameters', :bad_request
      )
    end
  end

  private

  def confirm_schedule_params
    params.require(:expert_call).permit(:call_status)
  end
end
