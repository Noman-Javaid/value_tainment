require 'rails_helper'

RSpec.describe 'Api::V1::Individual::ExpertCalls::ConfirmReschedulesController',
               type: :request do
  let(:expert_call) do
    create(
      :expert_call, :requires_reschedule_confirmation, individual: individual,
                                                       expert: expert
    )
  end
  let(:expert_call_id) { 1 }
  let(:confirm_reschedule_expert_call_path) do
    api_v1_individual_expert_call_confirm_reschedule_path(expert_call_id: expert_call_id)
  end
  let(:confirmation_status) { 'extra_status' }
  let(:confirmation_params) do
    {
      expert_call: {
        call_status: confirmation_status
      }
    }
  end

  context 'with valid authentication and authorization data' do
    include_context 'users_for_individual_endpoints'
    describe 'PUT /api/v1/individual/expert_calls/:expert_call_id/confirm_reschedule' do
      let(:expert_call_id) { expert_call.id }
      let(:request) do
        put confirm_reschedule_expert_call_path, headers: auth_headers(user),
                                                 params: confirmation_params.to_json
      end

      context 'when expert_call is confirmed' do
        let(:confirmation_status) { 'scheduled' }

        before { request }

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/expert_call/create')
        end
      end

      context 'when expert_call is unavailable' do
        let(:confirmation_status) { 'scheduled' }

        before do
          create(
            :expert_call,
            :scheduled,
            expert: expert,
            scheduled_time_start: expert_call.scheduled_time_start
          )

          request
        end

        it_behaves_like 'fail JSON response with message',
                        :unprocessable_entity,
                        'This time slot is no longer available. You can decline the call or suggest a new time for the user.'
      end

      context 'when expert_call is declined' do
        let(:confirmation_status) { 'declined' }

        before { request }

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/expert_call/create')
        end
      end

      context 'when an invalid call_status is pass' do
        before { request }

        it_behaves_like 'error JSON response', :bad_request
      end

      context 'when the expert user is inactive' do
        let(:error_message) do
          'The resource could not be updated because the other User has an inactive account'
        end

        before do
          expert_call.expert.user.update(active: false)
          request
        end

        describe 'the expert_call can not be scheduled' do
          let(:confirmation_status) { 'scheduled' }

          it_behaves_like 'fail JSON response', :unprocessable_entity

          it 'returns the correct error data' do
            expect(json['message']).to eq(error_message)
          end
        end

        describe 'the expert_call can not be declined' do
          let(:confirmation_status) { 'declined' }

          it_behaves_like 'fail JSON response', :unprocessable_entity

          it 'returns the correct error data' do
            expect(json['message']).to eq(error_message)
          end
        end
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') do
      let(:execute) { put confirm_reschedule_expert_call_path, headers: headers }
    end
  end

  context 'with authorization errors' do
    let(:user) { create(:user, :expert) }

    it_behaves_like('being an unauthorized user') do
      let(:execute) do
        put confirm_reschedule_expert_call_path, headers: auth_headers(user)
      end
    end
  end

  context 'with a disabled account' do
    let(:user) { create(:user, active: false) }

    it_behaves_like('being a disabled user') do
      let(:execute) do
        put confirm_reschedule_expert_call_path, headers: auth_headers(user)
      end
    end
  end
end
