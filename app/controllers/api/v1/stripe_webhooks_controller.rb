class Api::V1::StripeWebhooksController < Api::V1::ApiController
  skip_before_action :authenticate_user!
  skip_before_action :check_user_activity

  def receive
    event = fetch_event

    return json_error_response('Invalid request data', :bad_request) unless fetch_event

    begin
      Webhooks::StripeWebhookService.new(event).handle
    rescue Webhooks::Errors::UnhandledEventType => e
      return json_error_response(e.message, :bad_request)
    rescue StandardError
      return json_error_response(nil, :bad_request)
    end

    render json: nil, status: :ok
  end

  private

  def fetch_event
    payload = request.raw_post
    signature_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SIGNATURE'] # rubocop:todo Rails/EnvironmentVariableAccess

    begin
      # This approach automatically checks the signatures
      Stripe::Webhook.construct_event(payload, signature_header, endpoint_secret)

      # This approach handles Stripe::Event directly
      # Stripe::Event.construct_from(
      #   JSON.parse(payload, symbolize_names: true)
      # )
    rescue JSON::ParserError, Stripe::SignatureVerificationError
      nil
    end
  end
end
