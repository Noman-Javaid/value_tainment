require 'rails_helper'

RSpec.describe 'Api::V1::Expert::Availability::TimeSlotsController', type: :request do
  let(:expert_availability_time_slots) do
    api_v1_expert_availability_time_slots_path
  end

  context 'with valid authentication and authorization data' do
    include_context 'users_for_expert_endpoints'
    describe 'GET /api/v1/expert/availability/time_slots' do
      before do
        stub_const('ExpertCall::DEFAULT_CALL_DURATION', 20)
      end

      context 'when call_duration param is passed' do
        context 'with valid call_duration' do
          let(:params) { { call_duration: 15 } }

          before do
            get expert_availability_time_slots, headers: auth_headers(user), params: params
          end

          it_behaves_like 'success JSON response'

          it 'matches the expected schema' do
            expect(response).to match_json_schema('v1/availabilities/individual/show')
          end
        end

        context 'with invalid call_duration' do
          let(:params) { { call_duration: 10 } }

          before do
            get expert_availability_time_slots, headers: auth_headers(user), params: params
          end

          it_behaves_like 'error JSON response', :bad_request
        end
      end

      context 'when call_duration param is omitted' do
        before do
          get expert_availability_time_slots, headers: auth_headers(user)
        end

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/availabilities/individual/show')
        end
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') do
      let(:execute) { get expert_availability_time_slots, headers: headers }
    end
  end

  context 'with authorization errors' do
    let(:user) { create(:user) }

    it_behaves_like('being an unauthorized user') do
      let(:execute) { get expert_availability_time_slots, headers: auth_headers(user) }
    end
  end

  context 'with a disabled account' do
    let(:user) { create(:user, active: false) }

    it_behaves_like('being a disabled user') do
      let(:execute) { get expert_availability_time_slots, headers: auth_headers(user) }
    end
  end
end
