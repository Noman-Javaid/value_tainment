# frozen_string_literal: true

module Api
  module V1
    module Individual
      # TODO: remove this once the real videocall flow is working
      class ExpertCallRoomsController < Api::V1::Individual::IndividualsController
        ROOM_NAME = 'Business question'

        def create
          twilio_auth = Rails.application.credentials.dig(Rails.env.to_sym, :twilio)
          return head :ok, content_type: 'text/html' unless twilio_auth

          identity = current_user.email.split('@')[0]

          token = Twilio::JWT::AccessToken.new(twilio_auth[:account_sid],
                                               twilio_auth[:api_key], twilio_auth[:api_secret], [], identity: identity,
                                                                                                    ttl: 14400)
          grant = Twilio::JWT::AccessToken::VideoGrant.new
          grant.room = ROOM_NAME
          token.add_grant(grant)

          render json: {
            room_name: ROOM_NAME,
            token_jwt: token.to_jwt
          }
        end
      end
    end
  end
end
