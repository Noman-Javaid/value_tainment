class Api::V1::TwilioWebhooksController < Api::V1::ApiController
  skip_before_action :authenticate_user!
  skip_before_action :check_user_activity

  def receive
    # TODO
    # check the twilio signature in request

    # Webhooks::TwilioWebhookService.call(twilio_params.to_hash)
    # Webhooks::TwilioWebhookService.new(twilio_params.to_hash).call
    TwilioWebhookJob.perform_later(twilio_params.to_hash)
    render json: nil, status: :ok
  end

  private

  def twilio_params
    params.permit(
      :AccountSid, :RoomName, :RoomSid, :RoomStatus, :RoomType, :StatusCallbackEvent,
      :ParticipantSid, :ParticipantStatus, :ParticipantDuration, :ParticipantIdentity,
      :RoomDuration, :SequenceNumber, :Timestamp
    )
  end
end
