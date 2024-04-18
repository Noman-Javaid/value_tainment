require 'twilio-ruby'

module TwilioServices
  class CreateExpertCall < TwilioService
    def initialize(call_type, unique_name)
      super()
      @call_type = call_type
      @unique_name = unique_name
    end

    def call
      @client.video.rooms.create(
        type: @call_type,
        unique_name: @unique_name,
        status_callback: CREATE_ROOM_STATUS_CALLBACK,
        status_callback_method: CREATE_ROOM_STATUS_CALLBACK_METHOD
      )
    end
  end
end
