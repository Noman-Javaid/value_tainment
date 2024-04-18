require 'twilio-ruby'

module TwilioServices
  class EndExpertCall < TwilioService
    def initialize(room_id)
      super()
      @room_id = room_id
    end

    def call
      @client.video.rooms(@room_id).update(status: 'completed')
    end
  end
end
