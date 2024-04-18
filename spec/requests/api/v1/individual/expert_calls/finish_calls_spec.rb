require 'rails_helper'

RSpec.describe 'Api::V1::Individual::ExpertCalls::FinishCallsController', type: :request do
  let(:finish_expert_call_path) { finish_calls_api_v1_individual_expert_call_path(id: id) }
  let(:expert) { create(:expert, :with_profile, status: :verified) }
  let(:user) { create(:user, :with_profile) }
  let(:individual) { user.individual }
  let(:id) { 1 }

  context 'with valid authentication and authorization data' do
    describe 'PATCH /api/v1/individual/expert_calls/:id/finish_calls' do
      it_behaves_like 'finish_expert_call'
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') { let(:execute) { patch finish_expert_call_path, headers: headers } }
  end

  context 'with authorization errors' do
    let(:user) { create(:user, :expert) }

    it_behaves_like('being an unauthorized user') { let(:execute) { patch finish_expert_call_path, headers: auth_headers(user) } }
  end

  context 'with a disabled account' do
    let(:user) { create(:user, active: false) }

    it_behaves_like('being a disabled user') { let(:execute) { patch finish_expert_call_path, headers: auth_headers(user) } }
  end
end
