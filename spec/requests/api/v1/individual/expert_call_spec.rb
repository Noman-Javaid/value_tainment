require 'rails_helper'

RSpec.describe 'Api::V1::Individual::ExpertCallsController', type: :request do
  let(:expert_call_path) { api_v1_individual_expert_calls_path }
  let(:join_expert_call_path) { join_api_v1_individual_expert_call_path(id: id) }
  let(:category) { create(:category) }
  let(:id) { 1 }

  context 'with valid authentication and authorization data' do
    subject { post expert_call_path, headers: auth_headers(user), params: expert_call_data.to_json }

    include_context 'users_for_individual_endpoints'
    describe 'POST /api/v1/individual/expert_calls' do
      subject do
        post expert_call_path, headers: auth_headers(user),
                               params: expert_call_data.to_json
      end

      let(:guest_ids) { [] }
      let(:call_type) { ExpertCall::CALL_TYPE_ONE_TO_ONE }
      let(:expert_call_data) do
        {
          expert_call: {
            expert_id: expert.id,
            category_id: category.id,
            title: 'Call title',
            description: 'Call description',
            call_type: call_type,
            scheduled_time_start: scheduled_time_start.strftime('%FT%T.%LZ'),
            stripe_payment_method_id: 'pm_sjlkf023jr',
            guest_ids: guest_ids
          }
        }
      end

      let!(:scheduled_time_start) do
        20.minutes.from_now
      end
      let(:scheduled_time_end) do
        ExpertCall::DEFAULT_CALL_DURATION.minutes.from_now(
          scheduled_time_start
        ).strftime('%FT%T.%LZ')
      end
      context 'with a verified Expert' do
        include_context 'with stripe mocks and stubs for payments creation success'

        before { subject } # rubocop:todo RSpec/NamedSubject

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/expert_call/create')
        end

        context 'with guest_ids related to inviduals' do
          let(:call_type) { ExpertCall::CALL_TYPE_ONE_TO_FIVE }
          let(:guest_individuals) { create_list(:individual, 3) }
          let(:guest_ids) { guest_individuals.map(&:id) }

          before { subject } # rubocop:todo RSpec/NamedSubject

          # satisfied by parent context
          context 'with a valid guests' do
            it_behaves_like 'success JSON response'
          end

          context 'with invalid guests' do
            let(:guest_user) { create(:user, active: false) }
            let(:guest_individuals) { [create(:individual, user: guest_user)] }

            it_behaves_like 'fail JSON response', :unprocessable_entity
          end
        end
      end

      context 'when expert call is created it also creates a transaction' do
        include_context 'with stripe mocks and stubs for payments creation success'
        let(:charge_type) { 'payment_intent_confirmation' }
        let(:transaction) { Transaction.where(charge_type: charge_type).first }

        it_behaves_like 'transaction is created after interaction creation'
      end

      context 'when the Expert is not yet verified' do
        include_context 'with stripe mocks and stubs for payments creation success'
        let(:expert) { create(:expert, :with_profile, status: :pending, user: create(:user)) }

        before { subject } # rubocop:todo RSpec/NamedSubject

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/expert_call/create')
        end
      end

      context 'when the Expert is not active' do
        before do
          expert.user.update!(active: false)
          subject # rubocop:todo RSpec/NamedSubject
        end

        let(:error_message) { 'The Expert User is inactive at the moment' }

        it_behaves_like 'fail JSON response', :unprocessable_entity

        it 'returns the correct error data' do
          expect(json['message']).to eq(error_message)
        end
      end

      context 'when the stripe api call fails with api connection error' do
        include_context 'with stripe mocks and stubs for payment intent creation with '\
                        'api connection error'
        let(:error_message_response) { 'Payment service unavailable' }

        before { subject } # rubocop:todo RSpec/NamedSubject

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

      context 'when the stripe api call fails with api connection error' do
        include_context 'with stripe mocks and stubs for payment intent creation with '\
                        'api connection error'
        let(:error_message_response) { 'Payment service unavailable' }

        before { subject }

        it_behaves_like 'fail JSON response', :service_unavailable

        it 'returns the correct error message' do
          expect(json['message']).to eq(error_message_response)
        end
      end

      context 'when the stripe api call fails with card error' do
        include_context 'with stripe mocks and stubs for payment intent creation with '\
                        'card error'
        let(:error_message_response) { "A payment error occurred: #{error_message}" }

        before { subject }

        it_behaves_like 'fail JSON response', :unprocessable_entity

        it 'returns the correct error message' do
          expect(json['message']).to eq(error_message_response)
        end
      end
    end

    describe 'GET /api/v1/individual/expert_calls' do
      let!(:pending_calls) do
        create_list(:expert_call, 2, individual: individual)
      end
      let!(:scheduled_calls) do
        create_list(:expert_call, 2, :scheduled, individual: individual)
      end
      let!(:ongoing_calls) do
        create_list(:expert_call, 1, :ongoing, individual: individual)
      end
      let!(:declined_calls) do
        create_list(:expert_call, 2, :declined, individual: individual)
      end
      let!(:pending_to_reschedule_calls) do
        create_list(
          :expert_call, 3, :requires_reschedule_confirmation, individual: individual
        )
      end
      let!(:expert_calls_as_guest) do
        create_list(:expert_call, 2, :with_1to5, guest_ids: [individual.id])
      end

      context 'with scheduled, ongoing, and declined calls within result' do
        let(:expected_list_size) do
          scheduled_calls.size + ongoing_calls.size + declined_calls.size +
            pending_to_reschedule_calls.size + pending_calls.size +
            expert_calls_as_guest.size
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
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') { let(:execute) { post expert_call_path, headers: headers } }
    it_behaves_like('having an authentication error') { let(:execute) { get expert_call_path, headers: headers } }
  end

  context 'with authorization errors' do
    let(:user) { create(:user, :expert) }

    it_behaves_like('being an unauthorized user') { let(:execute) { post expert_call_path, headers: auth_headers(user) } }
    it_behaves_like('being an unauthorized user') { let(:execute) { get expert_call_path, headers: auth_headers(user) } }
  end

  context 'with a disabled account' do
    let(:user) { create(:user, :individual, active: false) }

    it_behaves_like('being a disabled user') { let(:execute) { post expert_call_path, headers: auth_headers(user) } }
    it_behaves_like('being a disabled user') { let(:execute) { get expert_call_path, headers: auth_headers(user) } }
  end
end
