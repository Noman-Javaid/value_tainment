require 'rails_helper'

RSpec.describe 'Api::V1::Individual::QuickQuestions::AttachmentsController', type: :request do
  let(:quick_question) do
    create(:quick_question, individual: individual, expert: expert)
  end
  let(:attachment) { create(:attachment, in_bucket: true, quick_question: quick_question) }
  let(:id) { 1 }
  let(:attachment_path) do
    api_v1_individual_quick_question_attachment_path(quick_question_id: id)
  end

  context 'with valid authentication and authorization data' do
    include_context 'Aws mocks and stubs'
    include_context 'users_for_individual_endpoints'
    describe 'GET /api/v1/individual/quick_questions/:quick_question_id/attachment' do
      let(:id) { quick_question.id }

      context 'when quick_question has attachment' do
        before do
          attachment
          get attachment_path, headers: auth_headers(user)
        end

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/expert/quick_questions/attachment/show')
        end
      end

      context 'when quick_question doesn\'t have attachment' do
        before do
          get attachment_path, headers: auth_headers(user)
        end

        it_behaves_like 'error JSON response', :not_found
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') do
      let(:execute) { get attachment_path, headers: headers }
    end
  end

  context 'with authorization errors' do
    let(:user) { create(:user, :expert) }

    it_behaves_like('being an unauthorized user') do
      let(:execute) { get attachment_path, headers: auth_headers(user) }
    end
  end

  context 'with a disabled account' do
    let(:user) { create(:user, :individual, active: false) }

    it_behaves_like('being a disabled user') do
      let(:execute) { get attachment_path, headers: auth_headers(user) }
    end
  end
end
