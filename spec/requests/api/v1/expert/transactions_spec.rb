require 'rails_helper'

RSpec.describe 'Api::V1::Expert::TransactionsController', type: :request do
  let(:transaction_path) { api_v1_expert_transactions_path }

  context 'with valid authentication and authorization data' do
    include_context 'users_for_expert_endpoints'
    include_context 'list of transactions'
    describe 'GET /api/v1/expert/transactions' do
      before do
        quick_questions_transactions
        expert_calls_transactions
        expert_calls_with_guests_transactions
        get transaction_path, headers: auth_headers(user), params: query_params
      end

      context 'when expert has transactions' do
        let(:query_params) { {} }

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/transactions/index')
        end

        it 'match the expected_list_size' do
          expect(json['data']['transactions'].size).to(
            eq(quick_questions_transactions.size + expert_calls_transactions.size +
              expert_calls_with_guests_transactions.size)
          )
        end
      end

      context 'with pagination' do
        let(:per_page) { 2 }
        let(:query_params) { { per_page: per_page, page: 1 } }

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/transactions/index')
        end

        it 'returns result quantity specified in per_page params' do
          expect(json['data']['transactions'].size).to eq(per_page)
        end
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') do
      let(:execute) { get transaction_path, headers: headers }
    end
  end

  context 'with authorization errors' do
    let(:user) { create(:user, :individual) }

    it_behaves_like('being an unauthorized user') do
      let(:execute) { get transaction_path, headers: auth_headers(user) }
    end
  end

  context 'with a disabled account' do
    let(:user) { create(:user, :expert, active: false) }

    it_behaves_like('being a disabled user') do
      let(:execute) { get transaction_path, headers: auth_headers(user) }
    end
  end
end
