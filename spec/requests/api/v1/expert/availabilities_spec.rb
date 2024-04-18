require 'rails_helper'

RSpec.describe 'Api::V1::Expert::AvailabilitiesController', type: :request do
  let(:expert_availability_path) { api_v1_expert_availability_path }

  context 'with valid authentication and authorization data' do
    let(:user) { create(:user, :expert) }
    let(:expert) do
      user.expert.update(
        extra_user_rate: 5, quick_question_rate: 5,
        one_to_one_video_call_rate: 10, one_to_five_video_call_rate: 25
      )
      user.expert
    end

    describe 'PUT /api/v1/expert/availability' do
      let(:availability_params) do
        {
          expert_availability: {
            weekdays: {
              days: %w[monday tuesday wednesday],
              time_start: '09:00:00+00:00',
              time_end: '16:00:00+00:00'
            },
            weekend: {
              days: [],
              time_start: nil,
              time_end: nil
            }
          }
        }
      end

      before do
        put expert_availability_path, headers: auth_headers(user),
                                      params: availability_params.to_json
      end

      it_behaves_like 'success JSON response'

      it 'matches the expected schema' do
        expect(response).to match_json_schema('v1/availabilities/expert/show')
      end
    end

    describe 'GET /api/v1/expert/availability' do
      before do
        get expert_availability_path, headers: auth_headers(user)
      end

      it_behaves_like 'success JSON response'

      it 'matches the expected schema' do
        expect(response).to match_json_schema('v1/availabilities/expert/show')
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') { let(:execute) { put expert_availability_path, headers: headers } }
    it_behaves_like('having an authentication error') { let(:execute) { get expert_availability_path, headers: headers } }
  end

  context 'with authorization errors' do
    let(:user) { create(:user) }

    it_behaves_like('being an unauthorized user') { let(:execute) { put expert_availability_path, headers: auth_headers(user) } }
    it_behaves_like('being an unauthorized user') { let(:execute) { get expert_availability_path, headers: auth_headers(user) } }
  end

  context 'with a disabled account' do
    let(:user) { create(:user, :expert, active: false) }

    it_behaves_like('being a disabled user') { let(:execute) { put expert_availability_path, headers: auth_headers(user) } }
    it_behaves_like('being a disabled user') { let(:execute) { get expert_availability_path, headers: auth_headers(user) } }
  end
end
