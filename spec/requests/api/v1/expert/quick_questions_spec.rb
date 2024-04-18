require 'rails_helper'

RSpec.describe 'Api::V1::Expert::QuickQuestionsController', type: :request do
  let(:quick_question_path) { api_v1_expert_quick_questions_path }
  let(:individual) { create(:individual, :with_profile) }
  let(:user) { create(:user, :expert) }
  let(:expert) do
    user.expert.update(
      extra_user_rate: 5, quick_question_rate: 5,
      one_to_one_video_call_rate: 10, one_to_five_video_call_rate: 25
    )
    user.expert
  end

  context 'with valid authentication and authorization data' do
    describe 'GET /api/v1/expert/quick_questions' do
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

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/expert_quick_questions/index')
        end
      end
    end

    describe 'GET /api/v1/expert/quick_questions/:id' do
      let(:id) { quick_question.id }
      let(:quick_question_path) { api_v1_expert_quick_question_path(id: id) }

      before do
        get quick_question_path, headers: auth_headers(user)
      end

      context 'when the id is related to a question that belongs to the expert' do
        let(:quick_question) do
          create(:quick_question, individual: individual, expert: expert)
        end

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/expert_quick_questions/show')
        end
      end

      context 'when the id is related to a question that does not belong to the'\
              ' expert' do
        let(:quick_question) do
          create(:quick_question, individual: individual)
        end

        it_behaves_like 'fail JSON response', :not_found
      end

      # satisfied by parent
      context 'when the id does not match a question' do
        let(:id) { 'invalid_id' }

        it_behaves_like 'fail JSON response', :not_found
      end
    end

    describe 'PUT /api/v1/expert/quick_questions/:id' do
      let(:id) { quick_question.id }
      let(:quick_question_path) { api_v1_expert_quick_question_path(id: id) }
      let(:answer) { 'this is an answer' }
      let(:quick_question) do
        create(:quick_question, individual: individual, expert: expert)
      end
      let(:draft_hash) { {} }
      let(:answer_hash) { { quick_question: { answer: answer }.merge(draft_hash) } }
      let(:update_params) { answer_hash.to_json }
      let(:request) do
        put quick_question_path, headers: auth_headers(user), params: update_params
      end

      context 'when the question is answered successfully' do
        before do
          allow(Stripes::Payments::CapturePaymentHandler).to receive(:call).and_return(Transaction.new)
          request
        end

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/expert_quick_questions/show')
        end

        it 'returns a quick_question object with the corresponding status' do
          expect(json['data']['quick_question']).to include({ 'status' => 'answered' })
        end
      end

      context 'when the question is answered as a draft successfully' do
        let(:draft_hash) { { answered_as_draft: true } }

        before { request }

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/expert_quick_questions/show')
        end

        it 'returns a quick_question object with the corresponding status' do
          expect(json['data']['quick_question']).to(
            include({ 'status' => 'draft_answered' })
          )
        end
      end

      context 'when the question can not be draft_answered because individual user is '\
              'inactive' do
        let(:draft_hash) { { answered_as_draft: true } }
        let(:error_message) do
          'The resource could not be updated because the other User has an inactive account'
        end

        before do
          quick_question.individual.user.update!(active: false)
          request
        end

        it_behaves_like 'fail JSON response', :unprocessable_entity

        it 'returns the correct error data' do
          expect(json['message']).to eq(error_message)
        end
      end

      context 'when the id is related to a question that does not belong to the'\
              ' expert' do
        let(:quick_question) do
          create(:quick_question, individual: individual)
        end

        before { request }

        it_behaves_like 'fail JSON response', :not_found
      end

      # satisfied by parent
      context 'when the id does not match a question' do
        let(:id) { 'fail' }

        before { request }

        it_behaves_like 'fail JSON response', :not_found
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') { let(:execute) { get quick_question_path, headers: headers } }
    it_behaves_like('having an authentication error') do
      let(:execute) do
        get api_v1_expert_quick_question_path(id: 'some_id'), headers: headers
      end
    end
  end

  context 'with authorization errors' do
    let(:user) { create(:user, :individual) }

    it_behaves_like('being an unauthorized user') { let(:execute) { get quick_question_path, headers: auth_headers(user) } }
    it_behaves_like('being an unauthorized user') do
      let(:execute) do
        get(api_v1_expert_quick_question_path(id: 'some_id'), headers: auth_headers(user))
      end
    end
  end

  context 'with a disabled account' do
    let(:user) { create(:user, :expert, active: false) }

    it_behaves_like('being a disabled user') { let(:execute) { get quick_question_path, headers: auth_headers(user) } }
    it_behaves_like('being a disabled user') do
      let(:execute) do
        get(api_v1_expert_quick_question_path(id: 'some_id'), headers: auth_headers(user))
      end
    end
  end
end
