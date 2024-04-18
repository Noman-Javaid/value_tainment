require 'twilio-ruby'

module TwilioServices
  class GetVideoRoom < TwilioService
    def initialize(room_id)
      super()
      @room_id = room_id
    end

    def call
      @client.video.rooms(@room_id).fetch
    end
  end
end
