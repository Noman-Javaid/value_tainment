module TwilioServices
  class SendForceUpdateBySms < TwilioService
    def initialize(user, device)
      check_params(user, device)
      super()
      @user = user
      @device = device
      @resource = "+#{@user.phone_number}"
    end

    def call
      message = @client.messages
                       .create(
                         from: TWILIO_PHONE_NUMBER,
                         body: "#{TWILIO_FORCE_UPDATE_MESSAGE}\n #{@device.download_url}",
                         to: @resource
                       )
      Rails.logger.info("SMS to ******#{@resource.last(4)} had status #{message.status}")
      message
    rescue Twilio::REST::RestError => e
      Rails.logger.info("Error Sending Twilio SMS message -> #{e}")
      return OpenStruct.new(error: 'Invalid phone number to send force update message') if e.code == INVALID_PHONE_NUMBER_CODE

      Honeybadger.notify(e)
      OpenStruct.new(error: 'SMS service unavailable')
    end

    private

    def check_params(user, device)
      raise ArgumentError, 'Wrong type of user' unless user.is_a?(User)
      raise ArgumentError, 'No phone number associated with user' if user.phone_number.nil?
      raise ArgumentError, 'No device is associated with user' if !device.present?
    end

  end
end
