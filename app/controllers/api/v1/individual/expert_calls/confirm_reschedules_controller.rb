class Api::V1::Individual::ExpertCalls::ConfirmReschedulesController <
      Api::V1::Individual::ExpertCallsController
  before_action :set_expert_call, only: %i[update]
  def update
    case confirm_reschedule_params[:call_status]
    when 'declined'
      @expert_call.decline!
      # notification for rescheduled rejected
      Notifications::Experts::ExpertCallNotifier.new(@expert_call)
                                                .rejected_rescheduled_call
    when 'scheduled'
      unless @expert_call.available_to_scheduled?
        return json_error_response(
          'This time slot is no longer available. You can decline the call or suggest a new time for the user.', :unprocessable_entity
        )
      end
      @expert_call.reschedule!
      # room creation job
      ExpertCalls::CreateExpertCallJob.set(
        wait_until: 1.minute.ago(@expert_call.scheduled_time_start)
      ).perform_later(@expert_call.id)
      # notification for rescheduled call and about to start
      notifier = Notifications::Experts::ExpertCallNotifier.new(@expert_call)
      notifier.confirmed_rescheduled_call
      notifier.about_to_start

      Notifications::Individuals::ExpertCallNotifier.new(@expert_call).about_to_start

      # service to send push notification according to reminders
      Notifications::UpcomingEventReminderNotifier.new(@expert_call).execute
    else
      return json_error_response(
        'Invalid parameters', :bad_request
      )
    end
    render 'api/v1/individual/expert_calls/create'
  end

  private

  def set_expert_call
    @expert_call = @individual.expert_calls.find(params[:expert_call_id])
  end

  def confirm_reschedule_params
    params.require(:expert_call).permit(:call_status)
  end
end
