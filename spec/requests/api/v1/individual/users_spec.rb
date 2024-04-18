require 'rails_helper'

RSpec.describe 'Api::V1::Individual::UsersController', type: :request do
  context 'with valid authentication and authorization data' do
    describe 'PATCH /api/v1/individual/users' do
      let(:gender) { 'male' }

      context 'with individual user' do
        let(:user) { create(:user, :with_profile) }
        let(:user_data) do
          {
            user: {
              date_of_birth: '1999-04-05',
              gender: gender,
              phone_number: '098311543243',
              country: 'US',
              city: 'New York',
              zip_code: '100034'
            }
          }
        end

        before do
          patch api_v1_individual_user_path,
                headers: auth_headers(user),
                params: user_data.to_json
        end

        # satisfied in parent context
        context 'with valid user data' do
          it_behaves_like 'success JSON response'
          it_behaves_like 'correct structure response for individual profile'
        end

        context 'with invalid gender' do
          let(:gender) { 'male_fail' }

          it_behaves_like 'fail JSON response', :unprocessable_entity

          it 'returns the correct error data for last_name' do
            expect(json['message']).to eq('Gender is not included in the list')
          end
        end

        context 'with empty string as username' do
          let(:user_data) { super()[:user].merge!(username: '') }

          it 'sets username as nil' do
            expect(user.reload.individual.username).to be_nil
          end
        end

        context 'with valid username' do
          let(:user_data) { super()[:user].merge!(username: Faker::Name.first_name ) }

          it 'sets username' do
            expect(user.reload.individual.username).to be_present
          end
        end
      end

      context 'with individual user when password is sent' do
        let(:user_data) do
          {
            user: {
              date_of_birth: '1999-04-05',
              gender: 'male',
              phone_number: '098311543243',
              country: 'US',
              city: 'New York',
              zip_code: '100034',
              password: password
            }
          }
        end

        context 'with correct password' do
          let(:password) { '123456' }
          let(:user) { create(:user, password: password) }

          before do
            patch api_v1_individual_user_path,
                  headers: auth_headers(user),
                  params: user_data.to_json
          end

          it_behaves_like 'success JSON response'
          it_behaves_like 'correct structure response for individual profile'
        end

        context 'with incorrect password' do
          let(:password) { '123456' }
          let(:user) { create(:user) }

          before do
            patch api_v1_individual_user_path,
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
      let(:execute) { patch api_v1_individual_user_path, headers: headers }
    end
  end

  context 'with authorization errors' do
    let(:user) { create(:user, :expert) }

    it_behaves_like('being an unauthorized user') do
      let(:execute) { patch api_v1_individual_user_path, headers: auth_headers(user) }
    end
  end

  context 'with a disabled account' do
    let(:user) { create(:user, :individual, active: false) }

    it_behaves_like('being a disabled user') do
      let(:execute) { patch api_v1_individual_user_path, headers: auth_headers(user) }
    end
  end
end
