require 'rails_helper'

RSpec.describe 'Api::V1::Expert::AccountBalancesController', type: :request do
  let(:account_balance_path) { api_v1_expert_account_balance_path }

  context 'with valid authentication and authorization data' do
    let(:user) { create(:user, :expert) }
    let(:expert) do
      user.expert.update(
        extra_user_rate: 5, quick_question_rate: 5,
        one_to_one_video_call_rate: 10, one_to_five_video_call_rate: 25
      )
      user.expert
    end

    describe 'GET /api/v1/expert/account_balance' do
      before do
        get account_balance_path, headers: auth_headers(user)
      end

      it_behaves_like 'success JSON response'

      it 'matches the expected schema' do
        expect(response).to match_json_schema('v1/account_balances/show')
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') { let(:execute) { get account_balance_path, headers: headers } }
  end

  context 'with authorization errors' do
    let(:user) { create(:user) }

    it_behaves_like('being an unauthorized user') { let(:execute) { get account_balance_path, headers: auth_headers(user) } }
  end

  context 'with a disabled account' do
    let(:user) { create(:user, active: false) }

    it_behaves_like('being a disabled user') { let(:execute) { get account_balance_path, headers: auth_headers(user) } }
  end
end
