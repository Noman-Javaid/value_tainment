require 'phonelib'

module TwilioServices
  class SendUpdateBySms < TwilioService
    def initialize(user, message, event = 'general')
      check_params(user, message)
      super()
      @user = user
      @resource = "+#{@user.phone_number}"
      @message = message
      @event = event
    end

    def call
      message = @client.messages
                       .create(
                         from: get_from_number(@resource),
                         body: @message,
                         to: @resource
                       )
      Rails.logger.info("SMS to ******#{@resource.last(4)} had status #{message.status}")
      message
    rescue Twilio::REST::RestError => e
      Rails.logger.info("Error Sending Twilio SMS message -> #{e}")
      return OpenStruct.new(error: "Invalid phone number to #{@event} message") if e.code == INVALID_PHONE_NUMBER_CODE

      Honeybadger.notify(e)
      OpenStruct.new(error: 'SMS service unavailable')
    end

    private

    def check_params(user, message)
      raise ArgumentError, 'Wrong type of user' unless user.is_a?(User)
      raise ArgumentError, 'No phone number associated with user' if user.phone_number.nil?
      raise ArgumentError, 'No message is provided to send' unless message.present?
    end

    def uk_number?(number)
      begin
        phone = Phonelib.parse(number)
        phone.valid? && phone.valid_for_country?('GB')
      rescue => ex
        false
      end
    end

    def get_from_number(number)
      uk_number?(number) ? TWILIO_UK_PHONE_NUMBER : TWILIO_PHONE_NUMBER
    end

  end
end
