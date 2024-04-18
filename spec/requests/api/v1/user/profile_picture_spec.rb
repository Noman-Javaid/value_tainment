require 'rails_helper'

RSpec.describe 'Api::V1::User::ProfilePictureController', type: :request do
  let(:user_picture_path) { api_v1_user_profile_picture_update_path }
  let(:user) { create(:user, :with_profile) }
  let(:img) { fixture_file_upload('icon.png') }
  let(:txt) { fixture_file_upload('icon.txt') }

  context 'with valid authentication and authorization data' do
    describe 'PATCH /api/v1/user/profile_picture/update' do
      context 'with an image file' do
        before do
          patch user_picture_path,
                headers: auth_headers(user),
                params: {
                  user: {
                    picture: img
                  }
                }
        end

        it 'test the picture attached to user' do
          user.reload
          expect(user.picture).to be_attached
        end

        it_behaves_like 'success JSON response'

        it 'has an url_picture field in response' do
          expect(json['data']['user']['url_picture']).to be_present
        end
      end

      context 'with a file different than an image' do
        before do
          patch user_picture_path,
                headers: auth_headers(user),
                params: {
                  user: {
                    picture: txt
                  }
                }
        end

        it 'test the file not attached to user' do
          user.reload
          expect(user.picture).not_to be_attached
        end

        it_behaves_like 'fail JSON response', :unprocessable_entity
      end

      context 'without picture field' do
        before do
          patch '/api/v1/user/profile_picture/update',
                headers: auth_headers(user),
                params: {
                  user: {
                    new_field: 'test_value'
                  }
                }.to_json
        end

        it_behaves_like 'error JSON response', :bad_request
      end

      context 'with authentication errors' do
        it_behaves_like('having an authentication error') do
          let(:execute) do
            patch user_picture_path, headers: headers
          end
        end
      end

      context 'with a disabled account' do
        let(:user) { create(:user, active: false) }
        let(:user_data) do
          {
            user: { picture: 'some value' }
          }
        end

        it_behaves_like('being a disabled user') do
          let(:execute) do
            patch user_picture_path,
                  headers: auth_headers(user),
                  params: user_data.to_json
          end
        end
      end
    end
  end
end
