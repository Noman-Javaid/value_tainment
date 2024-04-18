# frozen_string_literal: true

class StripeService
  PERCENTAGE_FEE_VALUE = 0.2
  USD_CURRENCY_FACTOR = 100
  CURRENCY = 'usd'
  DEFAULT_PAYMENT_METHOD_TYPE = ['card'].freeze

  def initialize
  end

  def payment_method_attached(customer_id)
    individual = Individual.find_by(stripe_customer_id: customer_id)
    return unless individual

    individual.update(has_stripe_payment_method: true)
  end

  def account_updated(account)
    expert = Expert.find_by(stripe_account_id: account['id'])
    return unless expert

    transfers = account['capabilities']['transfers'] == 'active'
    card_payments = account['capabilities']['card_payments'] == 'active'
    expert.can_receive_stripe_transfers = if transfers && card_payments
                                            true
                                          else
                                            false
                                          end
    expert.save
  end

  def external_account_created(external_account)
    # Add an external_account to expert
    expert = Expert.find_by(stripe_account_id: external_account['account'])
    return unless expert

    expert.update!(
      stripe_bank_account_id: external_account['id'],
      bank_account_last4: external_account['last4']
    )
  end

  def payout_paid(payout)
    # After payout is paid add to expert total earnings and substract to pending events
    expert = Expert.find_by(stripe_bank_account_id: payout['destination'])
    return unless expert

    expert.add_to_total_earnings(payout['amount'])
    Notifications::Experts::PaymentNotifier.new(expert, payout['amount']/100).execute
  end
end
