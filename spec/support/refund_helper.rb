RSpec.shared_examples_for 'has a refund transaction' do
  it { expect(transaction_event).not_to be_nil }
  it { expect(transaction_event.charge_type).to eq(Transaction::CHARGE_TYPE_CANCELATION) }
end

RSpec.shared_examples_for 'does not have a refund transaction' do
  it { expect(transaction_event).to be_nil }
end

RSpec.shared_context 'refund event' do # rubocop:todo RSpec/ContextWording
  let(:transaction_event) do
    Transaction.find_by(expert_interaction: interaction.expert_interaction)
  end
  let(:amount) { interaction.total_payment }
end
