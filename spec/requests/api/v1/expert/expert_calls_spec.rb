require 'rails_helper'

RSpec.describe 'Api::V1::Expert::ExpertCallsController', type: :request do
  let(:expert_call_path) { api_v1_expert_expert_calls_path }

  context 'with valid authentication and authorization data' do
    include_context 'users_for_expert_endpoints'
    describe 'GET /api/v1/expert/expert_calls' do
      let!(:pending_calls) do
        create_list(:expert_call, 2, expert: expert)
      end
      let!(:scheduled_calls) do
        create_list(:expert_call, 2, :scheduled, expert: expert)
      end
      let!(:ongoing_calls) do
        create_list(:expert_call, 1, :ongoing, expert: expert)
      end
      let!(:declined_calls) do
        create_list(:expert_call, 2, :declined, expert: expert)
      end
      let!(:pending_to_reschedule_calls) do
        create_list(
          :expert_call, 3, :requires_reschedule_confirmation, expert: expert
        )
      end

      context 'with scheduled, ongoing calls within result' do
        let(:expected_list_size) do
          scheduled_calls.size + ongoing_calls.size + pending_calls.size +
            declined_calls.size + pending_to_reschedule_calls.size
        end

        before do
          get expert_call_path, headers: auth_headers(user)
        end

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/expert_call/index')
        end

        it 'match the expected_list_size' do
          expect(json['data']['expert_calls'].size).to eq(expected_list_size)
        end
      end

      context 'with pagination' do
        let(:per_page) { 2 }
        let(:query_params) { { per_page: per_page, page: 1 } }

        before do
          get expert_call_path, headers: auth_headers(user), params: query_params
        end

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/expert_call/index')
        end

        it 'returns result quantity specified in per_page params' do
          expect(json['data']['expert_calls'].size).to eq(per_page)
        end
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') { let(:execute) { get expert_call_path, headers: headers } }
  end

  context 'with authorization errors' do
    let(:user) { create(:user, :individual) }

    it_behaves_like('being an unauthorized user') { let(:execute) { get expert_call_path, headers: auth_headers(user) } }
  end

  context 'with a disabled account' do
    let(:user) { create(:user, :expert, active: false) }

    it_behaves_like('being a disabled user') { let(:execute) { get expert_call_path, headers: auth_headers(user) } }
  end
end
