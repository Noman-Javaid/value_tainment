require 'rails_helper'

describe Stripes::ExpertHandler do
  include_context 'users_for_expert_endpoints'
  include_context 'Stripe mocks and stubs'
  let(:expert_handler) { described_class.new(expert) }

  describe '#create_connect_account' do
    before do
      expert.update!(stripe_account_set: false, stripe_account_id: nil)
    end

    it 'returns a link for the user to finish his account creation' do
      expect(expert_handler.create_connect_account).to eq(account_link_url)
    end

    context 'when updates the expert fields related to stripe account creation' do
      before do
        expert_handler.create_connect_account
      end

      it 'has connected an Stripe account to the expert' do
        expect(expert.stripe_account_id).to eq(account_id)
      end

      it 'has an stripe_account_set field to true' do
        expect(expert.stripe_account_set).to eq(true)
      end
    end

    context 'when the expert already have a Stripe account set' do
      let(:old_account_id) { "#{account_id}-old" }

      before do
        expert.update!(stripe_account_id: old_account_id)
      end

      it 'does not change the expert\'s Stripe account' do
        expect { expert_handler.create_connect_account }.not_to(
          change(expert, :stripe_account_id)
        )
      end
    end
  end
end
