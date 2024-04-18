RSpec.shared_context 'with refund data for interaction' do
  let(:account_id) { 'ac_b97e32swq01' }
  let(:customer_id) { 'cus_5Lc4dqPktp8' }
  let(:payment_method_id) { 'pi_2Lo47dnPt1' }
  let(:payment_id) { 'pi_3KXBl7A3xt8sfcfk0Qy89Rip' }
  let(:metadata) do
    {
      expert_id: interaction.instance_of?(TimeAddition) ? interaction.expert_call.expert.id : interaction.expert.id,
      interaction_id: interaction.id,
      interaction_type: interaction.class.to_s
    }
  end
  let(:amount) { interaction.rate * Stripes::BaseService::USD_CURRENCY_FACTOR }
  let(:refund_data) do
    {
      payment_intent: interaction.payment_id,
      metadata: metadata,
      amount: amount
    }
  end
end
