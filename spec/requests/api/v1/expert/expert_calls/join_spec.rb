require 'rails_helper'

RSpec.describe 'Api::V1::Expert::ExpertCalls::JoinController', type: :request do
  let(:individual) { create(:individual, :with_profile) }
  let!(:user) { create(:user, :expert) }
  let(:expert) do
    user.expert.update(
      extra_user_rate: 5, quick_question_rate: 5,
      one_to_one_video_call_rate: 10, one_to_five_video_call_rate: 25
    )
    user.expert
  end
  let(:expert_call) do
    create(:expert_call, :ongoing, individual: individual, expert: expert)
  end
  let(:id) { 1 }
  let(:join_expert_call_path) do
    api_v1_expert_expert_calls_join_path(id: id)
  end

  context 'with valid authentication and authorization data' do
    describe 'POST /api/v1/expert/expert_calls/:id/join' do
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
          expect(response).to match_json_schema('v1/expert_call/join_expert')
        end
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') { let(:execute) { post join_expert_call_path, headers: headers } }
  end

  context 'with authorization errors' do
    let(:user) { create(:user) }

    it_behaves_like('being an unauthorized user') { let(:execute) { post join_expert_call_path, headers: auth_headers(user) } }
  end

  context 'with a disabled account' do
    let(:user) { create(:user, active: false) }

    it_behaves_like('being a disabled user') { let(:execute) { post join_expert_call_path, headers: auth_headers(user) } }
  end
end
