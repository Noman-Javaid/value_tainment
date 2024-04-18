require 'rails_helper'

RSpec.describe 'Api::V1::Expert::PaymentsController', type: :request do
  let(:public_key) { Rails.application.credentials.dig(Rails.env.to_sym, :stripe, :public_key) }
  let(:public_key_path) { api_v1_expert_payments_public_key_path }
  let(:connect_account_path) { api_v1_expert_payments_connect_account_path }

  xcontext 'with valid authentication and authorization data' do
    describe 'GET /api/v1/expert/payments/public_key' do
      let(:user) { create(:user, :expert) }

      before do
        get public_key_path, headers: auth_headers(user)
      end

      it_behaves_like 'success JSON response'

      it { expect(json['data']).to include('public_key') }

      it 'returns a correct public key' do
        expect(json['data']['public_key']).to eq(public_key)
      end
    end

    describe 'POST /api/v1/expert/payments/connect_account' do
      let(:user) { create(:user, :expert) }

      include_context 'Stripe mocks and stubs'

      before do
        post connect_account_path, headers: auth_headers(user)
      end

      # it_behaves_like 'success JSON response'

      xit { expect(json['data']).to include('account_link') }

      xit 'returns the correct link to finish the onboarding process' do
        expect(json['data']['account_link']).to eq(account_link_url)
      end
    end
  end

  xcontext 'with authentication errors' do
    it_behaves_like('having an authentication error') { let(:execute) { get public_key_path, headers: headers } }
    it_behaves_like('having an authentication error') { let(:execute) { post connect_account_path, headers: headers } }
  end

  xcontext 'with authorization errors' do
    let(:user) { create(:user) }

    it_behaves_like('being an unauthorized user') { let(:execute) { get public_key_path, headers: auth_headers(user) } }
    it_behaves_like('being an unauthorized user') { let(:execute) { post connect_account_path, headers: auth_headers(user) } }
  end

  xcontext 'with a disabled account' do
    let(:user) { create(:user, active: false) }

    it_behaves_like('being a disabled user') { let(:execute) { get public_key_path, headers: auth_headers(user) } }
    it_behaves_like('being a disabled user') { let(:execute) { post connect_account_path, headers: auth_headers(user) } }
  end
end
