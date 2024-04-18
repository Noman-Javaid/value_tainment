# frozen_string_literal: true

class TwilioService
  CREATE_ROOM_STATUS_CALLBACK = ENV['TWILIO_WEBHOOK_URL'] # rubocop:todo Rails/EnvironmentVariableAccess
  CREATE_ROOM_STATUS_CALLBACK_METHOD = ENV['TWILIO_WEBHOOK_METHOD'] # rubocop:todo Rails/EnvironmentVariableAccess
  PARTICIPANT_EVENTS = %w[participant-connected participant-disconnected].freeze
  ROOM_ENDED_EVENT = 'room-ended'
  TWILIO_AUTH = Rails.application.credentials.dig(Rails.env.to_sym, :twilio)
  TWILIO_PHONE_NUMBER = ENV['TWILIO_PHONE_NUMBER'] # rubocop:todo Rails/EnvironmentVariableAccess
  TWILIO_UK_PHONE_NUMBER = 'MINNECT'
  TWILIO_2FA_MESSAGE = 'Your two factor authentication code for MINNECT is:'
  TWILIO_FORCE_UPDATE_MESSAGE = I18n.t('general_messages.force_update')
  INVALID_PHONE_NUMBER_CODE = 21211

  def initialize
    @client = Twilio::REST::Client.new
  end

  def self.call(...)
    new(...).call
  end
end
