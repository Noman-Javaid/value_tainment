require 'rails_helper'

RSpec.describe 'Api::V1::Individual::ExpertCalls::JoinController', type: :request do
  let(:expert_call_path) { api_v1_individual_expert_calls_path }
  # let(:join_expert_call_path) { join_api_v1_individual_expert_call_path(id: id) }
  let(:expert) { create(:expert, :with_profile, status: :verified) }
  let(:user) { create(:user, :with_profile) }
  let(:individual) { user.individual }
  let(:category) { create(:category) }
  let(:id) { 1 }
  let(:join_expert_call_path) { join_api_v1_individual_expert_call_path(id: id) }

  context 'with valid authentication and authorization data' do
    describe 'POST /api/v1/individual/expert_calls/:id/join' do
      let(:expert_call) do
        create(:expert_call, :ongoing, individual: individual, expert: expert)
      end
      let(:id) { expert_call.id }
      let(:fake_token) { 't9eJjdHkyi0iJ02lsaWd8tZnBh03Y9MSIsaInR3ciI6bnV' }

      context 'when the twilio token has been created' do
        before do
          allow(TwilioServices::CreateAccessToken).to(
            receive(:call).and_return(fake_token)
          )
          allow_any_instance_of(ExpertCalls::CallDuration).to( # rubocop:todo RSpec/AnyInstance
            receive(:call).and_return(0)
          )
          post join_expert_call_path, headers: auth_headers(user)
        end

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/expert_call/join')
        end
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') { let(:execute) { post join_expert_call_path, headers: headers } }
  end

  context 'with authorization errors' do
    let(:user) { create(:user, :expert) }

    it_behaves_like('being an unauthorized user') { let(:execute) { post join_expert_call_path, headers: auth_headers(user) } }
  end

  context 'with a disabled account' do
    let(:user) { create(:user, active: false) }

    it_behaves_like('being a disabled user') { let(:execute) { post join_expert_call_path, headers: auth_headers(user) } }
  end
end
