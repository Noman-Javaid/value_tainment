class PaymentCommands::CapturePayment < PaymentCommands::Base
  prepend SimpleCommand

  attr_accessor :payment

  def initialize(payment)
    @payment = payment
  end

  def call
    (errors.add :error_message, I18n.t('payment.capture.errors.invalid_state')).then { return } unless payment.requires_capture?

    payment_captured = Stripe::PaymentIntent.capture(@payment.payment_id)
    payment.captured! if payment_captured.present?

  rescue => e
    notify_error(e)
    raise_exception("Payment service error occurred: #{e.message}")
  end
end
