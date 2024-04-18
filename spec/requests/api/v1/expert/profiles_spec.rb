require 'rails_helper'

RSpec.describe 'Api::V1::Expert::ProfilesController', type: :request do
  let(:profiles_path) do
    api_v1_expert_profiles_path
  end

  context 'with valid authentication and authorization data' do
    include_context 'users_for_expert_endpoints'
    describe 'POST /api/v1/expert/profiles' do
      let(:profile_params) do
        {
          profile: {
            username: 'username'
          }
        }.to_json
      end

      before do
        post profiles_path, headers: auth_headers(user), params: profile_params
      end

      it_behaves_like 'success JSON response'

      it 'matches the expected schema' do
        expect(response).to match_json_schema('v1/users/show')
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') do
      let(:execute) do
        post profiles_path, headers: headers
      end
    end
  end

  context 'with authorization errors' do
    let(:user) { create(:user, :individual) }

    it_behaves_like('being an unauthorized user') do
      let(:execute) do
        post profiles_path, headers: auth_headers(user)
      end
    end
  end

  context 'with a disabled account' do
    let(:user) { create(:user, :expert, active: false) }

    it_behaves_like('being a disabled user') do
      let(:execute) do
        post profiles_path, headers: auth_headers(user)
      end
    end
  end
end
