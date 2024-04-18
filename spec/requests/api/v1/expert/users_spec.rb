require 'rails_helper'

RSpec.describe 'Api::V1::Expert::UsersController', type: :request do
  context 'with valid authentication and authorization data' do
    describe 'PATCH /api/v1/expert/users' do
      context 'with expert user' do
        let(:user) { create(:user, :expert) }
        let!(:category1) { create(:category) }
        let!(:category2) { create(:category) }

        before do
          patch api_v1_expert_user_path,
                headers: auth_headers(user),
                params: user_data.to_json
        end

        context 'with valid user data' do
          let(:user_data) do
            {
              user: {
                date_of_birth: '1999-04-05',
                gender: 'male',
                phone_number: '098311543243',
                country: 'US',
                city: 'New York',
                zip_code: '100034',
                biography: 'I am knowledge about business',
                website_url: 'www.myweb.com',
                linkedin_url: 'www.linkedin.com/profile',
                twitter_url: 'www.twitter.com/profile',
                instagram_url: 'www.instagram.com/profile',
                quick_question_rate: 50,
                one_to_one_video_call_rate: 60,
                one_to_five_video_call_rate: 70,
                extra_user_rate: 50,
                slug: 'slug'
              },
              categories: [category1.id, category2.id]
            }
          end

          it_behaves_like 'success JSON response'
          it_behaves_like 'correct structure response for expert profile'
        end

        context 'with missing categories' do
          let(:user_data) do
            {
              user: {
                date_of_birth: '1999-04-05',
                gender: 'male',
                phone_number: '098311543243',
                country: 'US',
                city: 'New York',
                zip_code: '100034',
                biography: 'I am knowledge about business',
                website_url: 'www.myweb.com',
                linkedin_url: 'www.linkedin/profile.com',
                quick_question_rate: 50,
                one_to_one_video_call_rate: 60,
                one_to_five_video_call_rate: 70,
                extra_user_rate: 50,
                slug: 'slug'
              },
              categories: []
            }
          end

          it_behaves_like 'error JSON response', :bad_request
        end
      end

      context 'with expert user when password is sent' do
        let(:user) { create(:user, :expert) }
        let!(:category1) { create(:category) }
        let!(:category2) { create(:category) }
        let(:user_data) do
          {
            user: {
              date_of_birth: '1999-04-05',
              gender: 'male',
              phone_number: '098311543243',
              country: 'US',
              city: 'New York',
              zip_code: '100034',
              biography: 'I am knowledge about business',
              website_url: 'www.myweb.com',
              linkedin_url: 'www.linkedin.com/profile',
              twitter_url: 'www.twitter.com/profile',
              instagram_url: 'www.instagram.com/profile',
              quick_question_rate: 50,
              one_to_one_video_call_rate: 60,
              one_to_five_video_call_rate: 70,
              extra_user_rate: 50,
              password: password,
              slug: 'slug'
            },
            categories: [category1.id, category2.id]
          }
        end

        context 'with correct password' do
          let(:password) { '123456' }

          before do
            user.update!(password: password, password_confirmation: password)
            patch api_v1_expert_user_path,
                  headers: auth_headers(user),
                  params: user_data.to_json
          end

          context 'with valid user data' do
            it_behaves_like 'success JSON response'
            it_behaves_like 'correct structure response for expert profile'
          end
        end

        context 'with incorrect password' do
          let(:password) { '123456' }
          let(:user) { create(:user, :expert) }

          before do
            patch api_v1_expert_user_path,
                  headers: auth_headers(user),
                  params: user_data.to_json
          end

          it_behaves_like 'error JSON response', :bad_request

          it 'matches with the error message' do
            expect(json['message']).to eq('Invalid Password')
          end
        end
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') do
      let(:execute) { patch api_v1_expert_user_path, headers: headers }
    end
  end

  context 'with authorization errors' do
    let(:user) { create(:user, :individual) }

    it_behaves_like('being an unauthorized user') do
      let(:execute) { patch api_v1_expert_user_path, headers: auth_headers(user) }
    end
  end

  context 'with a disabled account' do
    let(:user) { create(:user, :expert, active: false) }

    it_behaves_like('being a disabled user') do
      let(:execute) { patch api_v1_expert_user_path, headers: auth_headers(user) }
    end
  end
end
