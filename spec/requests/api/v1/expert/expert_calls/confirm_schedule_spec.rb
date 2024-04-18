require 'rails_helper'

RSpec.describe 'Api::V1::Expert::ExpertCalls::ConfirmScheduleController', type: :request do
  let(:individual) { create(:individual, :with_profile) }
  let!(:user) { create(:user, :expert) }
  let(:expert) do
    user.expert.update(
      extra_user_rate: 5, quick_question_rate: 5,
      one_to_one_video_call_rate: 10, one_to_five_video_call_rate: 25
    )
    user.expert
  end
  let(:expert_call) do
    create(:expert_call, :scheduled, individual: individual, expert: expert)
  end
  let(:id) { 1 }
  let(:expert_call_confirm_schedule_path) do
    api_v1_expert_expert_calls_confirm_schedule_path(id: id)
  end

  before do
    allow(ExpertCalls::CreateExpertCallJob).to(
      receive_message_chain(:set, :perform_later).and_return(true) # rubocop:todo RSpec/MessageChain
    )
    allow(ExpertCalls::CheckEndExpertCallJob).to(
      receive_message_chain(:set, :perform_later).and_return(true) # rubocop:todo RSpec/MessageChain
    )
  end

  context 'with valid authentication and authorization data' do
    describe 'PUT /api/v1/expert/expert_calls/:id/confirm_schedule' do
      let(:expert_call) do
        create(:expert_call, individual: individual, expert: expert)
      end
      let(:id) { expert_call.id }
      let(:confirm_schedule_data) { { expert_call: { call_status: call_status } } }
      let(:request) do
        allow(Stripes::Payments::CapturePaymentHandler).to receive(:call).and_return(Transaction.new)
        put expert_call_confirm_schedule_path, headers: auth_headers(user),
                                               params: confirm_schedule_data.to_json
      end

      context 'when the expert_call has been scheduled' do
        let(:call_status) { 'scheduled' }

        before do
          allow(Stripes::Payments::CapturePaymentHandler).to receive(:call).and_return(Transaction.new)
          request
          expert_call.reload
        end

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/expert_call/create')
        end

        it 'has scheduled call_status' do
          expect(expert_call.call_status).to eq(call_status)
        end
      end

      context 'when the expert_call has been declined' do
        let(:call_status) { 'declined' }

        before do
          request
          expert_call.reload
        end

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/expert_call/create')
        end

        it 'has declined call_status' do
          expect(expert_call.call_status).to eq(call_status)
        end
      end

      context 'when the call status is given an invalid value' do
        let(:call_status) { 'some data' }

        before { request }

        it_behaves_like 'error JSON response', :bad_request

        it 'returns the correct error data' do
          expect(json['message']).to eq('Invalid parameters')
        end
      end

      context 'when the id does not match an expert_call' do
        let(:id) { 'fail' }
        let(:call_status) { 'some data' }

        before { request }

        it_behaves_like 'fail JSON response', :not_found
      end

      context 'when the id is related to an expert_call that does not belong to the'\
              ' expert' do
        let(:other_expert) { create(:expert, :with_profile, status: :verified) }
        let(:expert_call) do
          create(:expert_call, individual: individual, expert: other_expert)
        end
        let(:id) { expert_call.id }
        let(:call_status) { 'some data' }

        before { request }

        it_behaves_like 'fail JSON response', :not_found
      end

      context 'when the individual user is inactive' do
        let(:error_message) do
          'The resource could not be updated because the other User has an inactive account'
        end

        before do
          expert_call.individual.user.update!(active: false)
          request
        end

        describe 'the expert call can not be scheduled' do
          let(:call_status) { 'scheduled' }

          it_behaves_like 'fail JSON response', :unprocessable_entity

          it 'returns the correct error data' do
            expect(json['message']).to eq(error_message)
          end
        end

        describe 'the expert call can not be declined' do
          let(:call_status) { 'declined' }

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
      let(:execute) { put expert_call_confirm_schedule_path, headers: headers }
    end
  end

  context 'with authorization errors' do
    let(:user) { create(:user) }

    it_behaves_like('being an unauthorized user') do
      let(:execute) { put expert_call_confirm_schedule_path, headers: auth_headers(user) }
    end
  end

  context 'with a disabled account' do
    let(:user) { create(:user, active: false) }

    it_behaves_like('being a disabled user') do
      let(:execute) { put expert_call_confirm_schedule_path, headers: auth_headers(user) }
    end
  end
end
