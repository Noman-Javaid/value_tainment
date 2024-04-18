require 'rails_helper'

describe StripeService do
  include_context 'Stripe mocks and stubs'
  include_context 'users_for_expert_endpoints'
  let(:stripe_service) { described_class.new }

  describe '#account_updated' do
    before do
      expert.update!(stripe_account_id: account_id)
      stripe_service.account_updated(account_from_webhook)
      expert.reload
    end

    it 'has fetched and correctly set the can_receive_stripe_transfers field' do
      expect(expert.can_receive_stripe_transfers).to eq(true)
    end
  end

  describe '#payment_method_attached' do
    before do
      individual.update!(stripe_customer_id: customer_id)
      stripe_service.payment_method_attached(customer_id)
      individual.reload
    end

    it 'has fetched and correctly set the has_stripe_payment_method field' do
      expect(individual.has_stripe_payment_method).to eq(true)
    end
  end
end
