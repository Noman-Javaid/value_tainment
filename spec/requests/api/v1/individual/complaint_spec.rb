require 'rails_helper'

RSpec.describe 'Api::V1::Individual::ComplaintsController', type: :request do
  let(:complaint_path) { api_v1_individual_complaints_path }
  let(:expert) { create(:expert, :with_profile, status: :verified) }
  let(:user) { create(:user, :with_profile) }
  let(:individual) { user.individual }

  context 'with valid authentication and authorization data' do
    describe 'POST /api/v1/individual/complaints' do
      context 'when complaint about an expert with expert_interaction not provided' do
        let(:complaint) do
          {
            complaint: {
              expert_id: expert.id,
              content: 'my complaint'
            }
          }
        end

        before do
          post complaint_path, headers: auth_headers(user), params: complaint.to_json
        end

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/complaints/create')
        end
      end

      context 'when complaint about an expert with quick_question provided' do
        let(:quick_question) do
          create(:quick_question, :answered, individual: individual, expert: expert)
        end

        let(:expert_interaction_id) do
          quick_question.expert_interaction.id
        end

        let(:complaint) do
          {
            complaint: {
              expert_id: expert.id,
              content: 'my complaint',
              quick_question_id: quick_question.id
            }
          }
        end

        before do
          post complaint_path, headers: auth_headers(user), params: complaint.to_json
        end

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/complaints/create')
        end

        it 'has expert_interaction_id' do
          expect(json['data']['complaint']['expert_interaction_id']).to(
            eq(expert_interaction_id)
          )
        end
      end

      context 'when complaint about an expert with expert_call provided' do
        let(:expert_call) do
          create(:expert_call, :scheduled, individual: individual, expert: expert)
        end

        let(:expert_interaction_id) do
          expert_call.expert_interaction.id
        end

        let(:complaint) do
          {
            complaint: {
              expert_id: expert.id,
              content: 'my complaint',
              expert_call_id: expert_call.id
            }
          }
        end

        before do
          post complaint_path, headers: auth_headers(user), params: complaint.to_json
        end

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/complaints/create')
        end

        it 'has expert_interaction_id' do
          expect(json['data']['complaint']['expert_interaction_id']).to(
            eq(expert_interaction_id)
          )
        end
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') { let(:execute) { post complaint_path, headers: headers } }
  end

  context 'with authorization errors' do
    let(:user) { create(:user, :expert) }

    it_behaves_like('being an unauthorized user') { let(:execute) { post complaint_path, headers: auth_headers(user) } }
  end

  context 'with a disabled account' do
    let(:user) { create(:user, :individual, active: false) }

    it_behaves_like('being a disabled user') { let(:execute) { post complaint_path, headers: auth_headers(user) } }
  end
end
