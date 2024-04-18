class PaymentCommands::Base
  APP_PERCENTAGE_FEE_VALUE = 0.2
  EXPERT_PERCENTAGE_VALUE = 0.8
  USD_CURRENCY_FACTOR = 100
  CURRENCY = 'usd'.freeze
  CAPTURE_METHOD = 'manual'.freeze
  DEFAULT_PAYMENT_METHOD_TYPE = ['card'].freeze
  ERROR_ON_REQUIRES_ACTION = true
  CONFIRM = true

  def notify_error(error)
    Honeybadger.notify(error, context: error_context(self.class))
  end

  def error_context(klass = nil)
    @error_context ||= {
      related_to: klass,
      payable_entity_type: @payment.payable_type,
      payable_entity_id: @payment.payable_id,
      payment_id: @payment.id
    }
  end

  def amount_to_transfer_to_expert(amount, expert)
    @amount_to_transfer_to_expert ||= (amount * expert.payout_percentage_value).to_i
  end

  def amount_to_transfer_to_expert_in_dollars(amount, expert)
    @amount_to_transfer_to_expert_in_dollars ||= (amount_to_transfer_to_expert(amount, expert) / USD_CURRENCY_FACTOR).to_i
  end

  def raise_exception(error_message)
    raise StandardError.new(error_message)
  end
end
