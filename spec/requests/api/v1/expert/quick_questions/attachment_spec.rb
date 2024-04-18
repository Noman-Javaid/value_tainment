require 'rails_helper'

RSpec.describe 'Api::V1::Expert::QuickQuestions::AttachmentsController', type: :request do
  let(:quick_question) do
    create(:quick_question, individual: individual, expert: expert)
  end
  let(:attachment) { create(:attachment, in_bucket: true, quick_question: quick_question) }
  let(:attachment_not_in_bucket) { create(:attachment, quick_question: quick_question) }
  let(:id) { 1 }
  let(:attachment_path) do
    api_v1_expert_quick_question_attachment_path(quick_question_id: id)
  end
  let(:response_url) { 'https://amazon.s3/test_url' }
  let(:response_headers) do
    {
      'Content-type': 'text/plain',
      'Content-Disposition': "inline; filename=\"#{file_name}\"; filename*=UTF-8''#{file_name}"
    }
  end
  let(:url_headers_hash) { { url: response_url, headers: response_headers } }
  let(:file_name) { 'test_file.txt' }
  let(:file_type) { 'text/plain' }
  let(:wrong_file_type) { 'appplication/rtf' }
  let(:file_size) { 343211 }
  let(:correct_params) do
    {
      attachment: {
        file_name: file_name, file_type: file_type, file_size: file_size
      }
    }
  end
  let(:incorrect_params) do
    {
      attachment: {
        file_name: file_name, file_type: wrong_file_type, file_size: file_size
      }
    }
  end

  context 'with valid authentication and authorization data' do
    include_context 'Aws mocks and stubs'
    include_context 'users_for_expert_endpoints'
    describe 'GET /api/v1/expert/quick_questions/:quick_question_id/attachment' do
      let(:id) { quick_question.id }

      context 'when quick_question has attachment' do
        context 'when file is in bucket' do
          before do
            attachment
            get attachment_path, headers: auth_headers(user)
          end

          it_behaves_like 'success JSON response'

          it 'matches the expected schema' do
            expect(response).to match_json_schema('v1/expert/quick_questions/attachment/show')
          end
        end

        context 'when file is not in bucket' do
          before do
            attachment_not_in_bucket
            get attachment_path, headers: auth_headers(user)
          end

          it_behaves_like 'success JSON response'

          it 'matches the expected schema' do
            expect(response).to match_json_schema('v1/expert/quick_questions/attachment/show_wihout_url')
          end
        end
      end

      context 'when quick_question doesn\'t have attachment' do
        before do
          get attachment_path, headers: auth_headers(user)
        end

        it_behaves_like 'error JSON response', :not_found
      end
    end

    describe 'POST /api/v1/expert/quick_questions/:quick_question_id/attachment' do
      let(:id) { quick_question.id }

      context 'when quick_question is allow to upload an attachment' do
        context 'when quickquestion has pending status' do
          context 'with correct params' do
            before do
              allow(Stripes::Payments::CapturePaymentHandler).to receive(:call).and_return(Transaction.new)
              allow_any_instance_of(Aws::Buckets::Objects::PresignedUrl).to( # rubocop:todo RSpec/AnyInstance
                receive(:call).and_return(url_headers_hash)
              )
              post attachment_path, headers: auth_headers(user), params: correct_params.to_json
            end

            it_behaves_like 'success JSON response'

            it 'matches the expected schema' do
              expect(response).to match_json_schema('v1/expert/quick_questions/attachment/create')
            end
          end

          context 'with incorrect params' do
            before do
              post attachment_path, headers: auth_headers(user), params: incorrect_params.to_json
            end

            it_behaves_like 'error JSON response', :unprocessable_entity
          end
        end

        context 'when quickquestion has draft_answer status' do
          before do
            quick_question.set_as_draft_answered!
          end

          context 'with correct params' do
            before do
              allow_any_instance_of(Aws::Buckets::Objects::PresignedUrl).to( # rubocop:todo RSpec/AnyInstance
                receive(:call).and_return(url_headers_hash)
              )
              post attachment_path, headers: auth_headers(user), params: correct_params.to_json
            end

            it_behaves_like 'success JSON response'

            it 'matches the expected schema' do
              expect(response).to match_json_schema('v1/expert/quick_questions/attachment/create')
            end
          end

          context 'with incorrect params' do
            before do
              post attachment_path, headers: auth_headers(user), params: incorrect_params.to_json
            end

            it_behaves_like 'error JSON response', :unprocessable_entity
          end
        end
      end

      context 'when quick_question is not allow to upload an attachment' do
        context 'when quickquestion has answered status' do
          before do
            allow(Stripes::Payments::CapturePaymentHandler).to receive(:call).and_return(Transaction.new)
            quick_question.update(answer: 'answer', answer_date: Time.current)
            post attachment_path, headers: auth_headers(user), params: correct_params.to_json
          end

          it_behaves_like 'error JSON response', :precondition_failed
        end
      end
    end

    describe 'PUT /api/v1/expert/quick_questions/:quick_question_id/attachment' do
      let(:id) { quick_question.id }
      let(:update_params) do
        {
          attachment: {
            in_bucket: true
          }
        }.to_json
      end

      context 'when quick_question is allow to upload an attachment' do
        before do
          allow(Stripes::Payments::CapturePaymentHandler).to receive(:call).and_return(Transaction.new)
          quick_question.set_as_draft_answered!
          attachment
          put attachment_path, headers: auth_headers(user), params: update_params
        end

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/expert/quick_questions/attachment/show')
        end
      end

      context 'when quick_question is not allow to upload an attachment' do
        before do
          allow(Stripes::Payments::CapturePaymentHandler).to receive(:call).and_return(Transaction.new)
          quick_question.update(answer: 'answer', answer_date: Time.current)
          put attachment_path, headers: auth_headers(user), params: update_params
        end

        it_behaves_like 'error JSON response', :precondition_failed
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') do
      let(:execute) { get attachment_path, headers: headers }
    end
    it_behaves_like('having an authentication error') do
      let(:execute) { post attachment_path, headers: headers }
    end
    it_behaves_like('having an authentication error') do
      let(:execute) { put attachment_path, headers: headers }
    end
  end

  context 'with authorization errors' do
    let(:user) { create(:user) }

    it_behaves_like('being an unauthorized user') do
      let(:execute) { get attachment_path, headers: auth_headers(user) }
    end
    it_behaves_like('being an unauthorized user') do
      let(:execute) { post attachment_path, headers: auth_headers(user) }
    end
    it_behaves_like('being an unauthorized user') do
      let(:execute) { put attachment_path, headers: auth_headers(user) }
    end
  end

  context 'with a disabled account' do
    let(:user) { create(:user, active: false) }

    it_behaves_like('being a disabled user') do
      let(:execute) { get attachment_path, headers: auth_headers(user) }
    end
    it_behaves_like('being a disabled user') do
      let(:execute) { post attachment_path, headers: auth_headers(user) }
    end
    it_behaves_like('being a disabled user') do
      let(:execute) { put attachment_path, headers: auth_headers(user) }
    end
  end
end
