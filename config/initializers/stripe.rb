Stripe.api_key = Rails.application.credentials.dig(Rails.env.to_sym, :stripe, :secret_key)
Stripe.api_version = '2020-08-27'
