# frozen_string_literal: true

module ExpertCalls
  class CheckEndExpertCallJob < ApplicationJob
    queue_as :high

    def perform(expert_call_id)
      @expert_call = ExpertCall.find(expert_call_id)
      twilio_video_room = TwilioServices::GetVideoRoom.call(@expert_call.room_id)
      case twilio_video_room.status
      when 'in-progress'
        # check for any consideration to end twilio room later
        check_call_time
      when 'completed'
        incomplete_call(twilio_video_room.end_time)
      end
    end

    private

    def check_call_time
      total_call_duration = ExpertCalls::CallDuration.new(@expert_call).call
      minutes_left_to_end_call = ((@expert_call.call_time - total_call_duration) * 60).to_i

      if minutes_left_to_end_call > ExpertCall::MINUTES_TIME_LEFT_TO_END_CALL
        execute_check_end_expert_call_job(
          minutes_left_to_end_call - ExpertCall::MINUTES_TIME_LEFT_TO_END_CALL
        )
      elsif minutes_left_to_end_call <= 0
        twilio_call = TwilioServices::EndExpertCall.call(@expert_call.room_id)
        complete_call(twilio_call.end_time)
      else
        # 2 minutes left to end call notificiation and finish call
        # send_time_left_notification
        execute_check_end_expert_call_job(ExpertCall::MINUTES_TIME_LEFT_TO_END_CALL)
      end
    end

    def execute_check_end_expert_call_job(minutes_left_to_end_call)
      ExpertCalls::CheckEndExpertCallJob.set(
        wait_until: minutes_left_to_end_call.minutes.from_now(Time.current)
      ).perform_later(@expert_call.id)
    end

    # send push notification about time left to end call
    def send_time_left_notification
      devices = ExpertCalls::GetDeviceList.new(@expert_call).call
      devices.each do |device|
        PushNotification::SenderJob.perform_later(
          device, ExpertCall::TIME_LEFT_MESSAGE
        )
      end
    end

    def complete_call(time_end)
      @expert_call.update_status_to_finish
      @expert_call.update!(time_end: time_end)
    end

    def incomplete_call(time_end)
      return if @expert_call.finished?

      @expert_call.set_as_incompleted if @expert_call.ongoing?
      @expert_call.update!(
        time_end: time_end
      )
    end
  end
end
