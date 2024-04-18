class TwilioWebhookJob < ApplicationJob
  queue_as :high

  def perform(twilio_params)
    Webhooks::TwilioWebhookService.new(twilio_params).call
  rescue StandardError => e
    Rails.logger.info("Errors Processing Twilio Webhook Service -> #{e}")
    Honeybadger.notify(e)
  end
end
