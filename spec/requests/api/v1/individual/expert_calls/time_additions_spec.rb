require 'rails_helper'

RSpec.describe 'Api::V1::Individual::ExpertCalls::TimeAdditionsController',
               type: :request do
  let(:expert_call_id) { 1 }
  let(:time_addition_path) do
    api_v1_individual_expert_call_time_additions_path(expert_call_id: expert_call_id)
  end

  context 'with valid authentication and authorization data' do
    include_context('users_for_individual_endpoints')
    describe 'POST /api/v1/individual/expert_calls/:expert_call_id/time_additions' do
      let(:expert_call) do
        create(:expert_call, :ongoing, individual: individual, expert: expert)
      end
      let(:expert_call_id) { expert_call.id }

      before { expert_device }

      context 'when time_addition has been created without params' do
        before do
          post time_addition_path, headers: auth_headers(user)
        end

        it_behaves_like 'success JSON response'

        it 'when should match the expected schema' do
          expect(response).to match_json_schema('v1/expert_call/time_addition/create')
        end
      end

      context 'when time_addition has been created with params' do
        let(:time_addition_data) do
          { time_addition: { duration: TimeAddition::DURATION } }
        end

        before do
          post time_addition_path, headers: auth_headers(user),
                                   params: time_addition_data.to_json
        end

        it_behaves_like 'success JSON response'

        it 'when should match the expected schema' do
          expect(response).to match_json_schema('v1/expert_call/time_addition/create')
        end
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') do
      let(:execute) { post time_addition_path, headers: headers }
    end
  end

  context 'with authorization errors' do
    let(:user) { create(:user, :expert) }

    it_behaves_like('being an unauthorized user') do
      let(:execute) { post time_addition_path, headers: auth_headers(user) }
    end
  end

  context 'with a disabled account' do
    let(:user) { create(:user, active: false) }

    it_behaves_like('being a disabled user') do
      let(:execute) { post time_addition_path, headers: auth_headers(user) }
    end
  end
end
