module TwilioServices
  class CreateConversation < TwilioService
    def initialize(expert_call_id)
      super()
      @expert_call_id = expert_call_id
    end

    def call
      room_name = chat_room_name
      # create chat room at twilio side
      conversation = @client.conversations.v1.conversations.create(friendly_name: room_name)
      Rails.logger.info("Chat room created with sid: #{conversation.sid}")
      chat_room = ChatRoom.find_or_initialize_by(expert_call_id: @expert_call_id)

      # adding expert to the chat room
      expert_chat_access_token = create_chat_grant(expert_call.expert.id, conversation.chat_service_sid)

      # Create Chat grant for our token
      individual_access_token = create_chat_grant(expert_call.individual.id, conversation.chat_service_sid)

      chat_room.update(
        sid: conversation.sid,
        name: room_name,
        status: 'active',
        room_data: { chat_service_id: conversation.chat_service_sid,
                     sid: conversation.sid,
                     state: conversation.state,
                     url: conversation.url,
                     links: conversation.links,
                     expert_access_token: expert_chat_access_token,
                     individual_access_token: individual_access_token }
      )

      chat_room
    rescue Twilio::REST::RestError => e
      Rails.logger.info("Error Creating Twilio chat room -> #{e}")
      Honeybadger.notify(e)
      { error: 'Twilio chat service unavailable' }
    end

    private

    def chat_room_name
      "#{Faker::Superhero.unique.name}_#{@expert_call_id}"
    end

    def expert_call
      @expert_call ||= ExpertCall.find @expert_call_id
    end

    def create_chat_grant(identity, chat_service_sid)
      twilio_auth = TWILIO_AUTH
      grant = Twilio::JWT::AccessToken::ChatGrant.new
      grant.service_sid = chat_service_sid
      token = Twilio::JWT::AccessToken.new(
        twilio_auth[:account_sid], twilio_auth[:api_key], twilio_auth[:api_secret],
        [grant], identity: identity, ttl: 86400
      )
      token.to_jwt
    end
  end
end
