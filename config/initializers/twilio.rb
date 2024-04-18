Twilio.configure do |config|
  config.account_sid = Rails.application.credentials.dig(Rails.env.to_sym, :twilio, :account_sid)
  config.auth_token = Rails.application.credentials.dig(Rails.env.to_sym, :twilio, :auth_token)
end
