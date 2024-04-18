require 'rails_helper'

RSpec.describe 'Api::V1::Expert::ExpertCalls::TimeAdditions::ConfirmsController',
               type: :request do
  let(:expert_call_id) { 1 }
  let(:time_addition_id) { 1 }
  let(:confirm_time_addition_path) do
    api_v1_expert_expert_call_time_addition_confirm_path(
      expert_call_id: expert_call_id, time_addition_id: time_addition_id
    )
  end

  context 'with valid authentication and authorization data' do
    include_context('users_for_expert_endpoints')
    describe 'PATCH /api/v1/expert/expert_calls/:expert_call_id/time_additions/:id/confirm' do
      subject { patch confirm_time_addition_path, headers: auth_headers(user), params: confirmation_params.to_json }

      let(:expert_call) do
        create(:expert_call, :ongoing, individual: individual, expert: expert)
      end
      let(:expert_call_id) { expert_call.id }
      let(:time_addition) { create(:time_addition, expert_call: expert_call) }
      let(:time_addition_id) { time_addition.id }
      let(:confirmation_params) { { time_addition: { status: 'confirmed' } } }

      context 'when time_addition has been confirmed' do
        include_context 'with stripe mocks and stubs for payments creation success'

        before do
          stub_request(:post, "https://api.stripe.com/v1/payment_intents/pi_xxx/capture").to_return(status: 200, body: "", headers: {})
          individual_device
          subject # rubocop:todo RSpec/NamedSubject
        end

        it_behaves_like 'success JSON response'

        it 'when should match the expected schema' do
          expect(response).to match_json_schema('v1/expert_call/time_addition/create')
        end
      end

      context 'when time_addition is confirmed it also creates a transaction' do
        include_context 'with stripe mocks and stubs for payments creation success'
        let(:charge_type) { 'payment_intent_confirmation' }
        let(:transaction) { Transaction.where(charge_type: charge_type).first }

        before {
          stub_request(:post, "https://api.stripe.com/v1/payment_intents/pi_xxx/capture").to_return(status: 200, body: "", headers: {})
          individual_device
        }

        it_behaves_like 'transaction is created after interaction creation'
      end

      context 'when the stripe api call fails with api connection error' do
        include_context 'with stripe mocks and stubs for payment intent creation with '\
                        'api connection error'
        let(:error_message_response) { 'Payment service unavailable' }

        before { stub_request(:post, "https://api.stripe.com/v1/payment_intents/pi_xxx/capture").to_return(status: 200, body: "", headers: {})
        subject } # rubocop:todo RSpec/NamedSubject

        it_behaves_like 'fail JSON response', :service_unavailable

        it 'returns the correct error message' do
          expect(json['message']).to eq(error_message_response)
        end
      end

      context 'when the stripe api call fails with card error' do
        include_context 'with stripe mocks and stubs for payment intent creation with '\
                        'card error'
        let(:error_message_response) { "A payment error occurred: #{error_message}" }

        before { subject } # rubocop:todo RSpec/NamedSubject

        it_behaves_like 'fail JSON response', :unprocessable_entity

        it 'returns the correct error message' do
          expect(json['message']).to eq(error_message_response)
        end
      end

      context 'when time_addition has been declined' do
        let(:confirmation_params) { { time_addition: { status: 'declined' } } }

        before do
          individual_device
          subject # rubocop:todo RSpec/NamedSubject
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
      let(:execute) { patch confirm_time_addition_path, headers: headers }
    end
  end

  context 'with authorization errors' do
    let(:user) { create(:user) }

    it_behaves_like('being an unauthorized user') do
      let(:execute) { patch confirm_time_addition_path, headers: auth_headers(user) }
    end
  end

  context 'with a disabled account' do
    let(:user) { create(:user, active: false) }

    it_behaves_like('being a disabled user') do
      let(:execute) { patch confirm_time_addition_path, headers: auth_headers(user) }
    end
  end
end
