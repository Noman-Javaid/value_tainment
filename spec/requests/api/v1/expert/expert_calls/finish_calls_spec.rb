require 'rails_helper'

RSpec.describe 'Api::V1::Expert::ExpertCalls::FinishCallsController', type: :request do
  let(:finish_expert_call_path) { finish_calls_api_v1_expert_expert_call_path(id: id) }
  let(:individual) { create(:individual, :with_profile) }
  let!(:user) { create(:user, :expert) }
  let(:expert) do
    user.expert.update(
      extra_user_rate: 5, quick_question_rate: 5,
      one_to_one_video_call_rate: 10, one_to_five_video_call_rate: 25
    )
    user.expert
  end
  let(:id) { 1 }

  context 'with valid authentication and authorization data' do
    describe 'PATCH /api/v1/expert/expert_calls/:id/finish_calls' do
      it_behaves_like 'finish_expert_call'
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') { let(:execute) { patch finish_expert_call_path, headers: headers } }
  end

  context 'with authorization errors' do
    let(:user) { create(:user) }

    it_behaves_like('being an unauthorized user') { let(:execute) { patch finish_expert_call_path, headers: auth_headers(user) } }
  end

  context 'with a disabled account' do
    let(:user) { create(:user, active: false) }

    it_behaves_like('being a disabled user') { let(:execute) { patch finish_expert_call_path, headers: auth_headers(user) } }
  end
end
