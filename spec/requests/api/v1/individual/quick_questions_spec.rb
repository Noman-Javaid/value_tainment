require 'rails_helper'

RSpec.describe 'Api::V1::Individual::QuickQuestionsController', type: :request do
  let(:quick_question_path) { api_v1_individual_quick_questions_path }

  let(:expert) { create(:expert, :with_profile, status: :verified) }
  let(:user) { create(:user, :with_profile) }
  let(:individual) do
    user.individual.update!(
      stripe_customer_id: 'cu_w04or8u23',
      has_stripe_payment_method: true
    )
    user.individual
  end

  context 'with valid authentication and authorization data' do
    subject { post quick_question_path, headers: auth_headers(user), params: quick_question_data.to_json }

    describe 'POST /api/v1/individual/quick_questions' do
      subject do
        post quick_question_path, headers: auth_headers(user),
                                  params: quick_question_data.to_json
      end

      let(:category) { create(:category) }
      let(:quick_question_data) do
        {
          quick_question: {
            expert_id: expert.id,
            question: 'Question value',
            description: 'my description',
            category_id: category.id,
            answer_type: 'choose',
            stripe_payment_method_id: 'pm_sjlkf023jr'
          }
        }
      end

      context 'with a verified Expert' do
        include_context 'with stripe mocks and stubs for payments creation success'

        before { subject } # rubocop:todo RSpec/NamedSubject

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/individual_quick_questions/show')
        end

        it { expect(json['data']).to include('quick_question') }

        it { expect(json['data']).to include('expert') }
      end

      context 'when the Expert is not yet verified' do
        include_context 'with stripe mocks and stubs for payments creation success'
        let(:expert) { create(:expert, :with_profile, status: :pending, user: create(:user, :with_profile)) }

        before { subject } # rubocop:todo RSpec/NamedSubject

        it_behaves_like 'success JSON response'
      end

      context 'when quick question is created it also creates a transaction' do
        include_context 'with stripe mocks and stubs for payments creation success'
        let(:charge_type) { 'payment_intent_confirmation' }
        let(:transaction) { Transaction.where(charge_type: charge_type).first }

        it_behaves_like 'transaction is created after interaction creation'
      end

      context 'when the Expert does not exist' do
        # rubocop:todo RSpec/ScatteredSetup
        before { subject } # rubocop:todo RSpec/NamedSubject
        # rubocop:enable RSpec/ScatteredSetup

        let(:expert) { OpenStruct.new(id: 'fake-id') }

        # rubocop:todo RSpec/ScatteredSetup
        before { subject } # rubocop:todo RSpec/NamedSubject
        # rubocop:enable RSpec/ScatteredSetup

        it_behaves_like 'fail JSON response', :unprocessable_entity
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

    describe 'GET /api/v1/individual/quick_questions' do
      include_context 'list of quick questions'

      it_behaves_like 'return pending question list'

      it_behaves_like 'return completed question list'

      it_behaves_like 'return all question list'

      it_behaves_like 'return a subset of quick_questions based on pagination'

      it_behaves_like 'return a subset of quick_questions based on limit and offset pagination'

      it_behaves_like 'return quick_question with a max limit of pagination'

      context 'when match the expected schema' do
        let(:query_params) { {} }

        before do
          get quick_question_path, headers: auth_headers(user), params: query_params
        end

        it 'matches the schema' do
          expect(response).to match_json_schema('v1/individual_quick_questions/index')
        end
      end
    end

    describe 'GET /api/v1/individual/quick_questions/:id' do
      let(:id) { 'fail' }
      let(:quick_question_path) { api_v1_individual_quick_question_path(id: id) }

      before do
        get quick_question_path, headers: auth_headers(user)
      end

      context 'when the id is related to a question that belongs to the individual' do
        let(:quick_question) do
          create(:quick_question, individual: individual, expert: expert)
        end
        let(:id) { quick_question.id }

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/individual_quick_questions/show')
        end
      end

      context 'when the id is related to a question that does not belong to the'\
        ' individual' do
        let(:quick_question) do
          create(:quick_question, expert: expert)
        end
        let(:id) { quick_question.id }

        it_behaves_like 'fail JSON response', :not_found
      end

      # satisfied by parent
      context 'when the id does not match an question' do
        it_behaves_like 'fail JSON response', :not_found
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') { let(:execute) { post quick_question_path, headers: headers } }
    it_behaves_like('having an authentication error') { let(:execute) { get quick_question_path, headers: headers } }
    it_behaves_like('having an authentication error') do
      let(:execute) do
        get api_v1_individual_quick_question_path(id: 'some_id'), headers: headers
      end
    end
  end

  context 'with authorization errors' do
    let(:user) { create(:user, :expert) }

    it_behaves_like('being an unauthorized user') { let(:execute) { post quick_question_path, headers: auth_headers(user) } }
    it_behaves_like('being an unauthorized user') { let(:execute) { get quick_question_path, headers: auth_headers(user) } }
    it_behaves_like('being an unauthorized user') do
      let(:execute) do
        get(api_v1_individual_quick_question_path(id: 'some_id'),
            headers: auth_headers(user))
      end
    end
  end

  context 'with a disabled account' do
    let(:user) { create(:user, :individual, active: false) }

    it_behaves_like('being a disabled user') { let(:execute) { post quick_question_path, headers: auth_headers(user) } }
    it_behaves_like('being a disabled user') { let(:execute) { get quick_question_path, headers: auth_headers(user) } }
    it_behaves_like('being a disabled user') do
      let(:execute) do
        get(api_v1_individual_quick_question_path(id: 'some_id'),
            headers: auth_headers(user))
      end
    end
  end
end
