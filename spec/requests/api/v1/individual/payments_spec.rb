require 'rails_helper'

RSpec.describe 'Api::V1::Individual::PaymentsController', type: :request do
  let(:public_key) { Rails.application.credentials.dig(Rails.env.to_sym, :stripe, :public_key) }
  let(:public_key_path) { api_v1_individual_payments_public_key_path }
  let(:ephemeral_key_path) { api_v1_individual_payments_ephemeral_key_path }

  context 'with valid authentication and authorization data' do
    describe 'GET /api/v1/individual/payments/public_key' do
      let(:user) { create(:user) }

      before do
        get public_key_path, headers: auth_headers(user)
      end

      it_behaves_like 'success JSON response'

      it { expect(json['data']).to include('public_key') }

      it 'returns a correct public key' do
        expect(json['data']['public_key']).to eq(public_key)
      end
    end

    describe 'GET /api/v1/individual/payments/ephemeral_key' do
      let(:user) { create(:user) }

      let(:ephemeral_key_response) do
        {
          id: 'ephkey_1JFWGXH4StbB2t7h2_fake',
          object: 'ephemeral_key',
          associated_objects: [
            { id: 'cus_JiIrJKaCIbFVa7', type: 'customer' }
          ],
          created: 1626838717,
          expires: 1626842317,
          livemode: false,
          secret: 'ek_test_YWNjdF8xSjMzVndINFN0YkIydDdoLHVDY3dnaWw5UHdD_fake'
        }
      end

      let(:mock_stripe_ephemeral_key_request) do
        stub_request(:post, 'https://api.stripe.com/v1/ephemeral_keys')
          .to_return(status: 200, body: ephemeral_key_response.to_json, headers: {})
      end

      before do
        mock_stripe_ephemeral_key_request
        get ephemeral_key_path, headers: auth_headers(user)
      end

      it_behaves_like 'success JSON response'

      it { expect(json['data']).to include('ephemeral_key') }

      context 'when the stripe customer related to the indiviual is not found' do
        let(:mock_stripe_ephemeral_key_request) do
          stub_request(:post, 'https://api.stripe.com/v1/ephemeral_keys')
            .to_return(status: 400, body: nil, headers: {})
        end

        it_behaves_like 'fail JSON response', :unprocessable_entity
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') { let(:execute) { get public_key_path, headers: headers } }
    it_behaves_like('having an authentication error') { let(:execute) { get ephemeral_key_path, headers: headers } }
  end

  context 'with authorization errors' do
    let(:user) { create(:user, :expert) }

    it_behaves_like('being an unauthorized user') { let(:execute) { get public_key_path, headers: auth_headers(user) } }
    it_behaves_like('being an unauthorized user') { let(:execute) { get ephemeral_key_path, headers: auth_headers(user) } }
  end

  context 'with a disabled account' do
    let(:user) { create(:user, active: false) }

    it_behaves_like('being a disabled user') { let(:execute) { get public_key_path, headers: auth_headers(user) } }
    it_behaves_like('being a disabled user') { let(:execute) { get ephemeral_key_path, headers: auth_headers(user) } }
  end
end
