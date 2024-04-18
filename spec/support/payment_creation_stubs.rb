RSpec.shared_context 'with payment creation constants stubs' do
  let(:confirm) { true }
  let(:currency) { 'usd' }
  let(:usd_currency_factor) { 100 }
  let(:app_percentage_value) { 0.2 }
  let(:expert_percentage_value) { 0.8 }
  let(:error_on_requires_action) { true }
  let(:payment_method_types) { ['card'] }

  before do
    stub_const('Stripes::Payments::BaseHandler::CONFIRM', confirm)
    stub_const('Stripes::Payments::BaseHandler::CURRENCY', currency)
    stub_const('Stripes::Payments::BaseHandler::USD_CURRENCY_FACTOR', usd_currency_factor)
    stub_const('Stripes::Payments::BaseHandler::APP_PERCENTAGE_FEE_VALUE', app_percentage_value)
    stub_const('Stripes::Payments::BaseHandler::EXPERT_PERCENTAGE_VALUE', expert_percentage_value)
    stub_const('Stripes::Payments::BaseHandler::ERROR_ON_REQUIRES_ACTION', error_on_requires_action)
    stub_const('Stripes::Payments::BaseHandler::DEFAULT_PAYMENT_METHOD_TYPE', payment_method_types)
  end
end

RSpec.shared_context 'with payment intent data for interaction' do
  let(:account_id) { 'ac_b97e32swq01' }
  let(:customer_id) { 'cus_5Lc4dqPktp8' }
  let(:payment_method_id) { 'pi_2Lo47dnPt1' }
  let(:amount) { interaction_rate * usd_currency_factor }
  let(:amount_to_transfer_to_expert) { amount * expert_percentage_value }
  let(:amount_to_transfer_to_expert_in_dollars) { amount_to_transfer_to_expert / usd_currency_factor }
  let(:payment_intent_data) do
    {
      amount: amount,
      customer: customer_id,
      payment_method: payment_method_id,
      confirm: confirm,
      currency: currency,
      payment_method_types: payment_method_types,
      payment_method_options: { card: { capture_method: "manual" } },
      error_on_requires_action: error_on_requires_action,
      metadata: {
        amount_to_transfer_to_expert: amount_to_transfer_to_expert,
        amount_to_transfer_to_expert_in_dollars: amount_to_transfer_to_expert_in_dollars,
        expert_id: expert.id,
        expert_connected_account_id: account_id,
        interaction_id: interaction.id,
        interaction_type: interaction.class.to_s
      }
    }
  end
end

RSpec.shared_context 'with payment intent data for time addtion' do
  let(:account_id) { 'ac_b97e32swq01' }
  let(:customer_id) { 'cus_5Lc4dqPktp8' }
  let(:payment_method_id) { 'pi_2Lo47dnPt1' }
  let(:amount) { interaction_rate * usd_currency_factor }
  let(:amount_to_transfer_to_expert) { amount * expert_percentage_value }
  let(:amount_to_transfer_to_expert_in_dollars) { amount_to_transfer_to_expert / usd_currency_factor }
  let(:individual) do
    create(:individual, :with_profile, stripe_customer_id: customer_id)
  end
  let(:payment_intent_data) do
    {
      amount: amount,
      customer: customer_id,
      payment_method: payment_method_id,
      confirm: confirm,
      currency: currency,
      payment_method_types: payment_method_types,
      error_on_requires_action: error_on_requires_action,
      payment_method_options: { card: { capture_method: "manual" } },
      metadata: {
        amount_to_transfer_to_expert: amount_to_transfer_to_expert,
        amount_to_transfer_to_expert_in_dollars: amount_to_transfer_to_expert_in_dollars,
        expert_id: expert.id,
        expert_connected_account_id: account_id,
        related_to_expert_call_id: expert_call.id,
        interaction_id: interaction.id,
        interaction_type: interaction.class.to_s
      }
    }
  end
end
