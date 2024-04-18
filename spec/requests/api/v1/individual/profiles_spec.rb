require 'rails_helper'

RSpec.describe 'Api::V1::Individual::ProfilesController', type: :request do
  let(:profiles_path) do
    api_v1_individual_profiles_path
  end

  context 'with valid authentication and authorization data' do
    include_context 'users_for_individual_endpoints'
    describe 'POST /api/v1/individual/profiles' do
      let(:category) { create(:category) }
      let(:profile_params) do
        {
          profile: {
            biography: 'My bio',
            website_url: 'https://www.mywebsite.com',
            linkedin_url: 'https://www.linkedin.com/myprofile',
            quick_question_rate: 50,
            one_to_one_video_call_rate: 60,
            one_to_five_video_call_rate: 70,
            extra_user_rate: 50
          },
          categories: [category.id]
        }
      end

      context 'when correct params are sent' do
        before do
          post profiles_path, headers: auth_headers(user), params: profile_params.to_json
        end

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/users/show')
        end
      end

      context 'when a param is missing' do
        before do
          profile_params[:profile][:biography] = nil
          post profiles_path, headers: auth_headers(user), params: profile_params.to_json
        end

        it_behaves_like 'error JSON response', :unprocessable_entity
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') do
      let(:execute) { post profiles_path, headers: headers }
    end
  end

  context 'with authorization errors' do
    let(:user) { create(:user, :expert) }

    it_behaves_like('being an unauthorized user') do
      let(:execute) { post profiles_path, headers: auth_headers(user) }
    end
  end

  context 'with a disabled account' do
    let(:user) { create(:user, :individual, active: false) }

    it_behaves_like('being a disabled user') do
      let(:execute) { post profiles_path, headers: auth_headers(user) }
    end
  end
end
