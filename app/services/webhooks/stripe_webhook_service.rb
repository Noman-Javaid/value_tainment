class Webhooks::StripeWebhookService
  def initialize(event, connected_account = nil)
    @event = event
    @connected_account = connected_account
  end

  # UPDATE: account.update for stripe connected accounts
  def handle
    case @event['type']
    when 'account.updated'
      # Occurs whenever an account status or property has changed.
      account = @event['data']['object']
      StripeService.new.account_updated(account)
    when 'payout.paid'
      # Occurs whenever a payout paid is made to an external_account.
      payout = @event['data']['object']
      StripeService.new.payout_paid(payout)
    when 'account.external_account.created'
      # Occurs whenever an account external_account is created.
      external_account = @event['data']['object']
      StripeService.new.external_account_created(external_account)
    when 'payment_method.attached'
      # Occurs whenever a payment_method is attached
      customer_id = @event['data']['object']['customer']
      StripeService.new.payment_method_attached(customer_id)
    else
      raise Webhooks::Errors::UnhandledEventType, @event
    end
  end
end
