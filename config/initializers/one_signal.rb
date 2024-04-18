OneSignal::OneSignal.api_key = Rails.application.credentials.dig(
  Rails.env.to_sym, :one_signal, :api_key
)
