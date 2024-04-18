# frozen_string_literal: true

module ExpertCalls
  class CreateExpertCallJob < ApplicationJob
    queue_as :high

    def perform(expert_call_id)
      expert_call = nil
      expert_call = ExpertCall.find(expert_call_id)
      return if expert_call.cancelled?
      expert_call.update!(room_status: 'in_progress')

      twilio_call = TwilioServices::CreateExpertCall.call(
        expert_call.twilio_call_type, expert_call.id
      )

      Rails.logger.info(expert_call_id: expert_call_id, event: 'room_creation', twilio_response: twilio_call)

      if twilio_call.status == 'failed'
        expert_call.fail
        expert_call.update!(room_status: 'failed', call_status: twilio_call.status)
        message = "Unable to create the twilio call room for the call #{expert_call_id}"
        raise StandardError.new(message)
      else
        expert_call.set_as_ongoing
        expert_call.update!(room_id: twilio_call.sid, room_status: 'created')
        expert_call.send_ongoing_call_notifications
      end
    rescue => ex
      Rails.logger.error(message: ex.message, expert_call: expert_call_id, event: 'twilio_room_creation_failed')
      Honeybadger.notify(ex)
      expert_call.update!(room_status: 'failed') if expert_call.present?
    end
  end
end
