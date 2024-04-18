module TwilioServices
  class CreateAccessToken < TwilioService
    def initialize(room_id, user_role_id) # rubocop:todo Lint/MissingSuper
      @room_id = room_id
      @user_role_id = user_role_id
    end

    def call
      twilio_auth = TWILIO_AUTH
      identity = @user_role_id
      grant = Twilio::JWT::AccessToken::VideoGrant.new
      grant.room = @room_id
      token = Twilio::JWT::AccessToken.new(
        twilio_auth[:account_sid], twilio_auth[:api_key], twilio_auth[:api_secret],
        [grant], identity: identity, ttl: 14400
      )
      token.to_jwt
    end
  end
end
