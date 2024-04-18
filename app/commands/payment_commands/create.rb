class PaymentCommands::Create
  prepend SimpleCommand
  def initialize(payable_entity, stripe_payment_method_id, amount, currency = 'USD')
    @stripe_payment_method_id = stripe_payment_method_id
    @payable_entity = payable_entity
    @amount = amount
    @currency = currency
  end

  def call
    Payment.create(payable: @payable_entity,
                   amount: (@amount * PaymentCommands::Base::USD_CURRENCY_FACTOR).to_i, # save the amount in cents
                   currency: @currency,
                   payment_method_id: @stripe_payment_method_id,
                   payment_method_types: %w[card])

  end
end
