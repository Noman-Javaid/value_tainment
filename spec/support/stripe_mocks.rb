RSpec.shared_context 'Stripe mocks and stubs' do # rubocop:todo RSpec/ContextWording
  # IMPROVEMENT refactor context separting for each case
  let(:payout_amount) { 100 }
  let(:account_id) { 'ct_123' }
  let(:customer_id) { 'cus_123' }
  let(:client_secret) { 'seti_123' }
  let(:account) { { 'id' => account_id } }
  let(:payment_intent_id) { 'pi_i38d922hf4d' }
  let(:payment_client_secret) { 'pi_p92i4dh71d' }
  let(:payout_destination_bank_account_id) { 'ba_123' }
  let(:setup_intent) { { 'client_secret' => client_secret } }
  let(:account_link) { OpenStruct.new(url: account_link_url) }
  let(:payment_method_webhook) { { 'customer' => customer_id } }
  let(:unknown_event_type) { { 'type' => 'unknown.event.type' } }
  let(:credit_card_list_object) { OpenStruct.new(data: credit_card_list) }
  let(:account_link_url) { 'https://connect.stripe.com/express/onboarding/3nEJa4k88J1w' }
  let(:credit_card_list) { [OpenStruct.new(id: 'card_f0dan32n4', brand: 'Visa', last4: '1234')] }
  let(:payment_intent) { { 'id' => payment_intent_id, 'client_secret' => payment_client_secret } }
  let(:payout_paid_event) { { 'type' => 'payout.paid', 'data' => { 'object' => payout_webhook } } }
  let(:payment_intent_object) { OpenStruct.new(id: 'pi_i4828d92d2ie2', status: 'requires_confirmation') }
  let(:payout_webhook) { { 'destination' => payout_destination_bank_account_id, 'amount' => payout_amount } }
  let(:account_updated_event) { { 'type' => 'account.updated', 'data' => { 'object' => account_from_webhook } } }
  let(:account_external_account_webhook) { { 'destination' => payout_destination_bank_account_id, 'amount' => payout_amount } }
  let(:account_from_webhook) { { 'id' => account_id, 'capabilities' => { 'transfers' => 'active', 'card_payments' => 'active' } } }
  let(:payment_method_attached_event) { { 'type' => 'payment_method.attached', 'data' => { 'object' => payment_method_webhook } } }
  let(:account_external_account_created_event) { { 'type' => 'account.external_account.created', 'data' => { 'object' => account_external_account_webhook } } }
  let(:paymenth_method_attached) { { 'type' => 'payment_method.attached', 'data' => { 'object' => { 'customer' => customer_id } } } }

  let(:paymenth_method_attached) { { 'type' => 'payment_method.attached', 'data' => { 'object' => { 'customer' => customer_id } } } }

  before do
    allow(Stripe::Account).to receive(:create).and_return(account)
    allow(Stripe::AccountLink).to receive(:create).and_return(account_link)

    allow(Stripe::SetupIntent).to receive(:create).and_return(setup_intent)

    allow(Stripe::PaymentIntent).to receive(:update).and_return(payment_intent_object)

    allow(Stripe::Customer).to receive(:list_sources).and_return(credit_card_list_object)

    # This must be done per-event in the specs
    # allow(Stripe::Webhook).to receive(:construct_event).and_return(an_event)
  end
end

RSpec.shared_context 'with stripe mocks and stubs for successfull payment confirmation' do
  let(:payment_intent_confirmed) do
    OpenStruct.new(
      id: 'pi_xxx', status: 'succeeded', amount: 1000
    )
  end

  before do
    allow(Stripe::PaymentIntent).to(
      receive(:confirm).with(any_args).and_return(payment_intent_confirmed)
    )
  end
end
RSpec.shared_context 'with stripe mocks and stubs for payment intent creation with '\
                     'rate limit error' do
  let(:param) { 'rate limit' }
  let(:error_message) { "Error with #{param}" }
  before do
    allow(Stripe::PaymentIntent).to(
      receive(:create).with(any_args).and_raise(
        Stripe::RateLimitError.new(error_message)
      )
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for payment confirmation' do
  let(:payment_intent_confirmed) do
    OpenStruct.new(
      id: interaction_payment_id, status: 'succeeded', amount: interaction_amount
    )
  end

  before do
    allow(Stripe::PaymentIntent).to(
      receive(:confirm).with(interaction_payment_id).and_return(payment_intent_confirmed)
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for payment intent creation with '\
                     'authentication error' do
  let(:param) { 'authentication error' }
  let(:error_message) { "Error with #{param}" }
  before do
    allow(Stripe::PaymentIntent).to(
      receive(:create).with(any_args).and_raise(
        Stripe::AuthenticationError.new(error_message)
      )
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for payment cancelation' do
  let(:payment_intent_canceled) do
    OpenStruct.new(
      id: interaction_payment_id, status: 'canceled', amount: interaction_amount
    )
  end

  before do
    allow(Stripe::PaymentIntent).to(
      receive(:cancel).with(interaction_payment_id).and_return(payment_intent_canceled)
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for payment intent creation with '\
                     'api connection error' do
  let(:param) { 'api connection error' }
  let(:error_message) { "Error with #{param}" }
  before do
    allow(Stripe::PaymentIntent).to(
      receive(:create).with(any_args).and_raise(
        Stripe::APIConnectionError.new(error_message)
      )
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for payment intent creation with '\
                     'card error' do
  let(:error_message) { 'Your card has insufficient funds.' }
  let(:param) { nil }
  before do
    allow(Stripe::PaymentIntent).to(
      receive(:create).with(any_args).and_raise(
        Stripe::CardError.new(error_message, param)
      )
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for payment confirmation error' do
  let(:param) { 'payment_method_' }
  let(:error_message) { "Error with #{param}" }
  before do
    allow(Stripe::PaymentIntent).to(
      receive(:confirm).with(interaction_payment_id).and_raise(
        Stripe::InvalidRequestError.new(error_message, param)
      )
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for payment intent creation with '\
                     'invalid request error' do
  let(:error_message) { 'Invalid payment method.' }
  let(:param) { nil }
  before do
    allow(Stripe::PaymentIntent).to(
      receive(:create).with(any_args).and_raise(
        Stripe::InvalidRequestError.new(error_message, param)
      )
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for payment cancelation error' do
  let(:param) { 'payment_method_' }
  let(:error_message) { "Error with #{param}" }
  before do
    allow(Stripe::PaymentIntent).to(
      receive(:cancel).with(interaction_payment_id).and_raise(
        Stripe::InvalidRequestError.new(error_message, param)
      )
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for payment intent creation with '\
                     'stripe error' do
  let(:error_message) { 'Generic error' }
  before do
    allow(Stripe::PaymentIntent).to(
      receive(:create).with(any_args).and_raise(
        Stripe::StripeError.new(error_message)
      )
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for payment requires_action' do
  let(:payment_intent_confirmed) do
    OpenStruct.new(id: interaction_payment_id, status: 'requires_action')
  end

  before do
    allow(Stripe::PaymentIntent).to(
      receive(:confirm).with(interaction_payment_id).and_return(payment_intent_confirmed)
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for payments creation success' do
  let(:payment_intent_confirmed) do
    OpenStruct.new(id: 'pi_xxx', status: 'succeeded', amount: '1000')
  end

  before do
    allow(Stripe::PaymentIntent).to(
      receive(:create).with(any_args).and_return(payment_intent_confirmed)
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for payment requires_action cancel' do
  let(:payment_intent_confirmed) do
    OpenStruct.new(id: interaction_payment_id, status: 'requires_action')
  end

  before do
    allow(Stripe::PaymentIntent).to(
      receive(:cancel).with(interaction_payment_id).and_return(payment_intent_confirmed)
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for successful payment creation' do
  let(:payment_id) { 'pi_xxxxxxxxxxxxxxxxxxxxxxxx' }
  let(:object) { 'payment_intent' }
  let(:status) { 'succeeded' }
  let(:payment_intent_object) do
    OpenStruct.new(id: payment_id, object: object, amount: amount, status: status)
  end

  before do
    allow(Stripe::PaymentIntent).to(
      receive(:create).with(payment_intent_data).and_return(payment_intent_object)
    )
  end
end

RSpec.shared_context 'with balance common values' do
  let(:object) { 'balance' }
  let(:livemode) { false }
  let(:source_types) { OpenStruct.new(card: 0) }
  let(:usd_amount_zero_object) do
    OpenStruct.new(amount: 0, currency: 'usd', source_types: source_types)
  end
  let(:eur_amount_zero_object) do
    OpenStruct.new(amount: 0, currency: 'eur', source_types: source_types)
  end
  let(:balance) do
    OpenStruct.new(
      object: object, available: available, connect_reserved: connect_reserved,
      pending: pending, livemode: livemode, instant_available: instant_available
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for balance retriever with no pending '\
                     'payouts' do
  include_context 'with balance common values'

  let(:available) { [usd_amount_zero_object, eur_amount_zero_object] }
  let(:instant_available) { [usd_amount_zero_object, eur_amount_zero_object] }
  let(:connect_reserved) { [usd_amount_zero_object, eur_amount_zero_object] }
  let(:pending) { [usd_amount_zero_object, eur_amount_zero_object] }

  before do
    allow(Stripe::Balance).to(
      receive(:retrieve).with(any_args).and_return(balance)
    )
  end
end

RSpec.shared_examples_for 'stripe api payment creation successful' do
  it 'stripe service is called once' do
    subject
    expect(Stripe::PaymentIntent).to(
      have_received(:create).with(payment_intent_data).once
    )
  end

  it 'returns the payment_intent_object' do
    expect(subject).to eq(payment_intent_object)
  end
end

RSpec.shared_context 'with stripe mocks and stubs for refund creation with '\
                     'rate limit error' do
  let(:param) { 'rate limit' }
  let(:error_message) { "Error with #{param}" }
  before do
    allow(Stripe::Refund).to(
      receive(:create).with(any_args).and_raise(
        Stripe::RateLimitError.new(error_message)
      )
    )
  end
end

# most common flow, since transfers from payment intents could take up to two days to
# arrive to the connected account
RSpec.shared_context 'with stripe mocks and stubs for balance retriever with pending '\
                     'payouts' do
  include_context 'with balance common values'

  let(:available) { [usd_amount_zero_object, eur_amount_zero_object] }
  let(:instant_available) { [usd_amount_zero_object, eur_amount_zero_object] }
  let(:connect_reserved) { [usd_amount_zero_object, eur_amount_zero_object] }
  let(:pending) do
    [OpenStruct.new(amount: 50000, currency: 'usd', source_types: OpenStruct.new(card: 50000)),
     eur_amount_zero_object]
  end

  before do
    allow(Stripe::Balance).to(
      receive(:retrieve).with(any_args).and_return(balance)
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for refund creation with '\
                     'authentication error' do
  let(:param) { 'authentication error' }
  let(:error_message) { "Error with #{param}" }
  before do
    allow(Stripe::Refund).to(
      receive(:create).with(any_args).and_raise(
        Stripe::AuthenticationError.new(error_message)
      )
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for refund creation with '\
                     'api connection error' do
  let(:param) { 'api connection error' }
  let(:error_message) { "Error with #{param}" }
  before do
    allow(Stripe::Refund).to(
      receive(:create).with(any_args).and_raise(
        Stripe::APIConnectionError.new(error_message)
      )
    )
  end
end

# uncommon flow, since payouts are scheduled to execute by default
RSpec.shared_context 'with stripe mocks and stubs for balance retriever with available '\
                     'payouts' do
  include_context 'with balance common values'

  let(:available) do
    [OpenStruct.new(amount: 50000, currency: 'usd', source_types: OpenStruct.new(card: 50000)),
     eur_amount_zero_object]
  end
  let(:instant_available) { [usd_amount_zero_object, eur_amount_zero_object] }
  let(:connect_reserved) { [usd_amount_zero_object, eur_amount_zero_object] }
  let(:pending) { [usd_amount_zero_object, eur_amount_zero_object] }

  before do
    allow(Stripe::Balance).to(
      receive(:retrieve).with(any_args).and_return(balance)
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for refund creation with '\
                     'invalid request error' do
  let(:error_message) { 'Invalid payment method.' }
  let(:param) { nil }
  before do
    allow(Stripe::Refund).to(
      receive(:create).with(any_args).and_raise(
        Stripe::InvalidRequestError.new(error_message, param)
      )
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for refund creation with '\
                     'stripe error' do
  let(:error_message) { 'Generic error' }
  before do
    allow(Stripe::Refund).to(
      receive(:create).with(any_args).and_raise(
        Stripe::StripeError.new(error_message)
      )
    )
  end
end

# uncommon flow, since instant_payouts (execution of payouts as soon as payment is
# completed [this is a premium feature currently not implemented]) are not handled
RSpec.shared_context 'with stripe mocks and stubs for balance retriever with '\
                     'instant_available payouts' do
  include_context 'with balance common values'

  let(:instant_available) do
    [OpenStruct.new(amount: 50000, currency: 'usd', source_types: OpenStruct.new(card: 50000)),
     eur_amount_zero_object]
  end
  let(:available) { [usd_amount_zero_object, eur_amount_zero_object] }
  let(:connect_reserved) { [usd_amount_zero_object, eur_amount_zero_object] }
  let(:pending) { [usd_amount_zero_object, eur_amount_zero_object] }

  before do
    allow(Stripe::Balance).to(
      receive(:retrieve).with(any_args).and_return(balance)
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for refunds creation success' do
  let(:refunds_confirmed) do
    OpenStruct.new(id: 're_xxx', status: 'succeeded', amount: '1000')
  end

  before do
    allow(Stripe::Refund).to(
      receive(:create).with(any_args).and_return(refunds_confirmed)
    )
  end
end

# uncommon flow, since connect_reserved (negative balances [not handling refunds]) are
# not handled
RSpec.shared_context 'with stripe mocks and stubs for balance retriever with '\
                     'connect_reserved payouts' do
  include_context 'with balance common values'

  let(:available) { [usd_amount_zero_object, eur_amount_zero_object] }
  let(:instant_available) { [usd_amount_zero_object, eur_amount_zero_object] }
  let(:connect_reserved) do
    [OpenStruct.new(amount: 50000, currency: 'usd', source_types: OpenStruct.new(card: 50000)),
     eur_amount_zero_object]
  end
  let(:pending) { [usd_amount_zero_object, eur_amount_zero_object] }

  before do
    allow(Stripe::Balance).to(
      receive(:retrieve).with(any_args).and_return(balance)
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for successful refund creation' do
  let(:refund_id) { 're_xxxxxxxxxxxxxxxxxxxxxxxx' }
  let(:object) { 'refund' }
  let(:status) { 'succeeded' }
  let(:refund_object) do
    OpenStruct.new(
      id: refund_id,
      object: object,
      payment_intent: payment_id,
      status: status,
      metadata: metadata,
      amount: amount
    )
  end

  before do
    allow(Stripe::Refund).to(
      receive(:create).with(refund_data).and_return(refund_object)
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for balance retriever with '\
                     'stripe error response' do
  let(:param) { 'account_id' }
  let(:error_message) { "Error with #{param}" }
  before do
    allow(Stripe::Balance).to(
      receive(:retrieve).with(any_args).and_raise(Stripe::StripeError.new(error_message))
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for balance retriever with '\
                     'rate limit error' do
  let(:param) { 'rate limit' }
  let(:error_message) { "Error with #{param}" }
  before do
    allow(Stripe::Balance).to(
      receive(:retrieve).with(any_args).and_raise(
        Stripe::RateLimitError.new(error_message)
      )
    )
  end
end

RSpec.shared_examples_for 'stripe api refund creation successful' do
  it 'stripe service is called once' do
    subject
    expect(Stripe::Refund).to(
      have_received(:create).with(refund_data).once
    )
  end

  it 'returns the refund_object' do
    expect(subject).to eq(refund_object)
  end
end

RSpec.shared_context 'with stripe mocks and stubs for transfer creation with '\
                     'rate limit error' do
  let(:param) { 'rate limit' }
  let(:error_message) { "Error with #{param}" }
  before do
    allow(Stripe::Transfer).to(
      receive(:create).with(any_args).and_raise(
        Stripe::RateLimitError.new(error_message)
      )
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for account deletion success' do
  let(:object) { 'account' }
  let(:id) { account_id }
  let(:deleted) { true }
  let(:account_deletion_response) do
    OpenStruct.new(object: object, id: id, deleted: deleted)
  end
  before do
    allow(Stripe::Account).to(
      receive(:delete).with(account_id).and_return(account_deletion_response)
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for transfer creation with '\
                     'authentication error' do
  let(:param) { 'authentication error' }
  let(:error_message) { "Error with #{param}" }
  before do
    allow(Stripe::Transfer).to(
      receive(:create).with(any_args).and_raise(
        Stripe::AuthenticationError.new(error_message)
      )
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for account deletion unsuccess' do
  let(:object) { 'account' }
  let(:id) { account_id }
  let(:deleted) { false }
  let(:account_deletion_response) do
    OpenStruct.new(object: object, id: id, deleted: deleted)
  end
  before do
    allow(Stripe::Account).to(
      receive(:delete).with(account_id).and_return(account_deletion_response)
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for transfer creation with '\
                     'api connection error' do
  let(:param) { 'api connection error' }
  let(:error_message) { "Error with #{param}" }
  before do
    allow(Stripe::Transfer).to(
      receive(:create).with(any_args).and_raise(
        Stripe::APIConnectionError.new(error_message)
      )
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for account deletion with '\
                     'stripe error response' do
  let(:param) { 'account_id' }
  let(:error_message) { "Error with #{param}" }
  before do
    allow(Stripe::Account).to(
      receive(:delete).with(any_args).and_raise(Stripe::StripeError.new(error_message))
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for transfer creation with '\
                     'card error' do
  let(:error_message) { 'Your card has insufficient funds.' }
  let(:param) { nil }
  before do
    allow(Stripe::Transfer).to(
      receive(:create).with(any_args).and_raise(
        Stripe::CardError.new(error_message, param)
      )
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for account deletion with '\
                     'rate limit error' do
  let(:param) { 'rate limit' }
  let(:error_message) { "Error with #{param}" }
  before do
    allow(Stripe::Account).to(
      receive(:delete).with(any_args).and_raise(
        Stripe::RateLimitError.new(error_message)
      )
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for transfer creation with '\
                     'invalid request error' do
  let(:error_message) { 'Invalid payment method.' }
  let(:param) { nil }
  before do
    allow(Stripe::Transfer).to(
      receive(:create).with(any_args).and_raise(
        Stripe::InvalidRequestError.new(error_message, param)
      )
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for user account deletion service' do
  let(:account_deletion_response) do
    OpenStruct.new(object: 'account', id: 'ac_xxx', deleted: true)
  end

  let(:customer_deletion_response) do
    OpenStruct.new(object: 'customer', id: 'cu_xxx', deleted: true)
  end

  before do
    allow(Stripe::Account).to(
      receive(:delete).with(any_args).and_return(account_deletion_response)
    )
    allow(Stripe::Customer).to(
      receive(:delete).with(any_args).and_return(customer_deletion_response)
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for transfer creation with '\
                     'stripe error' do
  let(:error_message) { 'Generic error' }
  before do
    allow(Stripe::Transfer).to(
      receive(:create).with(any_args).and_raise(
        Stripe::StripeError.new(error_message)
      )
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for payments confirmation success' do
  let(:payment_intent_confirmed) do
    OpenStruct.new(id: 'pi_xxx', status: 'succeeded', amount: '1000')
  end

  before do
    allow(Stripe::PaymentIntent).to(
      receive(:confirm).with(any_args).and_return(payment_intent_confirmed)
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for transfers creation success' do
  let(:transfer_confirmed) do
    OpenStruct.new(id: 'tr_xxx', amount: '1000')
  end

  before do
    allow(Stripe::Transfer).to(
      receive(:create).with(any_args).and_return(transfer_confirmed)
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for payments cancelation success' do
  let(:payment_intent_canceled) do
    OpenStruct.new(id: 'pi_xxx', status: 'canceled', amount: '1000')
  end

  before do
    allow(Stripe::PaymentIntent).to(
      receive(:canceled).with(any_args).and_return(payment_intent_canceled)
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for successful transfer creation' do
  let(:transfer_id) { 'tr_xxxxxxxxxxxxxxxxxxxxxxxx' }
  let(:object) { 'transfer' }
  let(:transfer_object) do
    OpenStruct.new(
      id: transfer_id,
      object: object,
      amount: amount,
      destination: account_id,
      balance_transaction: balance_transaction,
      destination_payment: destination_payment,
      reversed: reversed,
      metadata: metadata
    )
  end

  before do
    allow(Stripe::Transfer).to(
      receive(:create).with(transfer_data).and_return(transfer_object)
    )
  end
end

RSpec.shared_context 'with stripe mocks and stubs for payment intent confirmation with '\
                     'rate limit error' do
  let(:param) { 'rate limit' }
  let(:error_message) { "Error with #{param}" }
  before do
    allow(Stripe::PaymentIntent).to(
      receive(:confirm).with(any_args).and_raise(
        Stripe::RateLimitError.new(error_message)
      )
    )
  end
end

RSpec.shared_examples_for 'stripe api transfer creation successful' do
  it 'stripe service is called once' do
    subject
    expect(Stripe::Transfer).to(
      have_received(:create).with(transfer_data).once
    )
  end

  it 'returns the transfer_object' do
    expect(subject).to eq(transfer_object)
  end
end
