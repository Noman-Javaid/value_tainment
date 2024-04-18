class ExpertCalls::CreateRoomWorker
  include Sidekiq::Worker

  def perform(*args)
    current_time = Time.now.utc
    two_minutes_ahead = 2.minutes.from_now

    expert_calls = ExpertCall.where(scheduled_time_start: current_time..two_minutes_ahead)
    if expert_calls.present?
      expert_calls.each do |expert_call|
        return if  expert_call.room_status.present?

        return if expert_call.cancelled?

        expert_call.update!(room_status: 'in_progress')

        twilio_call = TwilioServices::CreateExpertCall.call(
          expert_call.twilio_call_type, expert_call.id
        )

        Rails.logger.info(expert_call_id: expert_call.id, event: 'room_creation', twilio_response: twilio_call)

        if twilio_call.status == 'failed'
          expert_call.fail
          expert_call.update!(room_status: 'failed', call_status: twilio_call.status)
          message = "Unable to create the twilio call room for the call #{expert_call.id}"
          raise StandardError.new(message)
        else
          expert_call.set_as_ongoing
          expert_call.update!(room_id: twilio_call.sid, room_status: 'created')
          expert_call.send_ongoing_call_notifications
        end
      rescue => ex
        Rails.logger.error(message: ex.message, expert_call: expert_call.id, event: 'twilio_room_creation_failed')
        Honeybadger.notify(ex)
        expert_call.update!(room_status: 'failed') if expert_call.present?
      end
    end
  end
end
