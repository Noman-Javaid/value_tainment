class PaymentCommands::CreatePaymentIntent < PaymentCommands::Base
  prepend SimpleCommand

  attr_accessor :payment

  def initialize(payment)
    @payment = payment
  end

  def call
    payment_intent = Stripe::PaymentIntent.create(payment_intent_params)
    payment.update(status: 'requires_capture', payment_id: payment_intent.id)  if payment_intent.present?
    payment_intent

  rescue => e
    notify_error(e)
    raise_exception("Payment service error occurred: #{e.message}")
  end

  private

  def payment_intent_params
    {
      payment_method: payment.payment_method_id,
      payment_method_types: payment.payment_method_types,
      amount: payment.amount.to_i,
      currency: payment.currency,
      customer: individual.stripe_customer_id,
      error_on_requires_action: PaymentCommands::Base::ERROR_ON_REQUIRES_ACTION,
      confirm: PaymentCommands::Base::CONFIRM,
      metadata: metadata,
      payment_method_options: {
        card: {
          capture_method: PaymentCommands::Base::CAPTURE_METHOD
        }
      }
    }
  end

  def metadata
    {
      amount_to_transfer_to_expert: amount_to_transfer_to_expert(payment.amount, expert),
      amount_to_transfer_to_expert_in_dollars: amount_to_transfer_to_expert_in_dollars(payment.amount, expert),
      expert_id: expert.id,
      expert_connected_account_id: expert.stripe_account_id,
      payment_id: payment.id,
      payable_id: payment.payable_id,
      payable_type: payment.payable_type
    }
  end

  def expert
    @expert ||= payment.payable.expert
  end

  def individual
    @individual ||= payment.payable.individual
  end
end
