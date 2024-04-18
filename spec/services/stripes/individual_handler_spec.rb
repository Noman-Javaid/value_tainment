require 'rails_helper'

describe Stripes::IndividualHandler do
  include_context 'Stripe mocks and stubs'
  let(:user) { create(:user, :individual) }
  let(:individual) { user.individual }
  let(:individual_handler) { described_class.new(individual) }

  describe '#create_customer' do
    let(:create_customer) { individual_handler.create_customer }

    it 'has created an Stripe customer for the individual' do
      create_customer

      expect(individual.stripe_customer_id).to eq(customer_id)
    end

    context 'when the individual already have a Stripe customer set' do
      let(:old_customer_id) { "#{customer_id}-old" }

      it "does not change the individuals's Stripe customer" do
        individual.stripe_customer_id = old_customer_id

        expect { create_customer }.not_to(
          change(individual, :stripe_customer_id)
        )
      end
    end
  end
end
