module Stripes
  module GlobalHelpers
    def self.included(base)
      base.let(:customer_id) { 'cus_123' }
      base.let(:customer) { { 'id' => customer_id } }
      base.let(:stripe_account_id) { 'cus_123' }
      base.let(:stripe_account) { { 'id' => stripe_account_id } }

      base.before do
        allow(Stripe::Customer).to receive(:create).and_return(customer)
        allow(Stripe::Account).to receive(:create).and_return(stripe_account)
      end
    end
  end
end
