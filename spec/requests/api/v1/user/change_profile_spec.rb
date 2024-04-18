require 'rails_helper'

RSpec.describe 'Api::V1::User::ChangeProfileController', type: :request do
  let(:change_profile_path) { api_v1_user_change_profile_path }

  context 'with valid authentication and authorization data' do
    let(:expert_params) do
      {
        biography: 'My bio',
        website_url: 'https://www.mywebsite.com',
        linkedin_url: 'https://www.linkedin.com/myprofile',
        twitter_url: 'www.twitter.com/profile',
        instagram_url: 'www.instagram.com/profile',
        quick_question_rate: 50,
        one_to_one_video_call_rate: 60,
        one_to_five_video_call_rate: 70,
        extra_user_rate: 50,
        slug: 'slug'
      }
    end
    let(:user) do
      user = create(:user, :with_profile)
      user.individual.username = 'my_username'
      user.create_expert!(expert_params)
      user
    end

    describe 'PATCH /api/v1/user/change_profile' do
      context 'when user has current_role as_individual' do
        before do
          user.update!(current_role: 'as_individual')
          patch change_profile_path, headers: auth_headers(user)
          user.reload
        end

        it 'changed role to expert' do
          expect(user).to be_as_expert
        end

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/users/show')
        end
      end

      context 'when user has current_role as_expert' do
        before do
          user.update!(current_role: 'as_expert')
          patch change_profile_path, headers: auth_headers(user)
          user.reload
        end

        it 'changed role to individual' do
          expect(user).to be_as_individual
        end

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/users/show')
        end
      end
    end
  end
end
