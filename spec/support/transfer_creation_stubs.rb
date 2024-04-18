RSpec.shared_context 'with transfer creation constants stubs' do
  let(:confirm) { true }
  let(:currency) { 'usd' }
  let(:usd_currency_factor) { 100 }
  let(:expert_percentage_value) { 0.8 }
  let(:error_on_requires_action) { true }
  let(:payment_method_types) { ['card'] }

  before do
    stub_const('Stripes::Transfers::TransferInteractionAmountHandler::CURRENCY', currency)
    stub_const('Stripes::Transfers::TransferInteractionAmountHandler::USD_CURRENCY_FACTOR', usd_currency_factor)
    stub_const('Stripes::Transfers::TransferInteractionAmountHandler::EXPERT_PERCENTAGE_VALUE', expert_percentage_value)
  end
end

RSpec.shared_context 'with transfer data for interaction' do
  let(:account_id) { 'ac_3ijod2i3923jei2hio' }
  let(:customer_id) { 'cus_5Lc4dqPktp8' }
  let(:payment_method_id) { 'pi_2Lo47dnPt1' }
  let(:balance_transaction) { 'bt_xxxxxxxxxx' }
  let(:destination_payment) { 'py_xxxxxxxxxx' }
  let(:reversed) { false }
  let(:amount) { interaction.rate * usd_currency_factor }
  let(:amount_to_transfer_to_expert) { amount * expert_percentage_value }
  let(:amount_to_transfer_to_expert_in_dollars) { amount_to_transfer_to_expert / usd_currency_factor }
  let(:metadata) do
    {
      expert_id: interaction.instance_of?(TimeAddition) ? interaction.expert_call.expert.id : interaction.expert.id,
      interaction_id: interaction.id,
      interaction_type: interaction.class.to_s
    }
  end
  let(:transfer_data) do
    {
      amount: amount_to_transfer_to_expert,
      currency: currency,
      destination: account_id,
      metadata: metadata
    }
  end
end
