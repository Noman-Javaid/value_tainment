require 'rails_helper'

RSpec.describe 'Api::V1::Individual::Payments::CreditCardsController', type: :request do
  let(:credit_card_list_path) { api_v1_individual_payments_credit_cards_path }

  context 'with valid authentication and authorization data' do
    describe 'GET /api/v1/individual/payments/credit_cards' do
      let(:user) { create(:user) }
      let!(:individual) do # rubocop:todo RSpec/LetSetup
        user.individual.update(stripe_customer_id: 'cu_i23iud3f90')
        user.individual
      end
      let(:credit_card_list_response) do
        {
          data: [
            {
              id: 'pm_1JIyKGA3xt8sfcfk59bybcoH',
              card: {
                brand: 'mastercard',
                last4: '4242'
              }
            }
          ],
          has_more: false
        }
      end

      let(:mock_stripe_get_credit_card_list_request) do
        stub_request(:get, 'https://api.stripe.com/v1/payment_methods?customer=cu_i23iud3f90&limit=10&type=card')
          .to_return(status: 200, body: credit_card_list_response.to_json, headers: {})
      end

      before do
        mock_stripe_get_credit_card_list_request
        get credit_card_list_path, headers: auth_headers(user)
      end

      it_behaves_like 'success JSON response'

      it 'matches the expected schema' do
        expect(response).to match_json_schema('v1/credit_cards/index')
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') { let(:execute) { get credit_card_list_path, headers: headers } }
  end

  context 'with authorization errors' do
    let(:user) { create(:user, :expert) }

    it_behaves_like('being an unauthorized user') { let(:execute) { get credit_card_list_path, headers: auth_headers(user) } }
  end

  context 'with a disabled account' do
    let(:user) { create(:user, active: false) }

    it_behaves_like('being a disabled user') { let(:execute) { get credit_card_list_path, headers: auth_headers(user) } }
  end
end
