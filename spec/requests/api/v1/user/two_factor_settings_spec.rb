require 'rails_helper'

RSpec.describe 'Api::V1::User::TwoFactorSettingsController', type: :request do
  let(:two_factor_settings_path) { api_v1_user_two_factor_settings_path }
  let(:new_two_factor_settings_path) { new_api_v1_user_two_factor_settings_path }
  let(:user) { create(:user, :with_profile) }

  context 'with valid authentication and authorization data' do
    describe 'GET /api/v1/user/two_factor_settings/new' do
      context 'with account_verified pending for validation' do
        include_context 'with Twilio mocks and stubs'

        before do
          get new_two_factor_settings_path, headers: auth_headers(user)
        end

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/users/two_factor_settings/new')
        end
      end

      context 'with account_verified already validated' do
        before do
          user.regenerate_two_factor_secret!
          user.enable_two_factor!
          get new_two_factor_settings_path, headers: auth_headers(user)
        end

        it_behaves_like 'error JSON response', :bad_request

        it 'match with the eror message' do
          expect(json['message']).to eq('Two factor authentication is already enabled')
        end
      end

      context 'when user has an invalid phone_number' do # rubocop:todo RSpec/RepeatedExampleGroupDescription
        include_context 'with Twilio sms error invalid number'

        before do
          get new_two_factor_settings_path, headers: auth_headers(user)
        end

        it_behaves_like 'error JSON response', :service_unavailable

        it 'match with the eror message' do
          expect(json['message']).to eq('Invalid phone number to send code')
        end
      end

      context 'when user has an invalid phone_number' do # rubocop:todo RSpec/RepeatedExampleGroupDescription
        include_context 'with Twilio unknown error'

        before do
          get new_two_factor_settings_path, headers: auth_headers(user)
        end

        it_behaves_like 'error JSON response', :service_unavailable

        it 'match with the eror message' do
          expect(json['message']).to eq('SMS service unavailable')
        end
      end
    end

    describe 'POST /api/v1/user/two_factor_settings' do
      let(:code) { user.current_otp.to_s }
      let(:params) { { two_factor_settings: { code: code } } }

      context 'with account_verified pending for validation' do
        before do
          user.regenerate_two_factor_secret!
          post two_factor_settings_path, headers: auth_headers(user), params: params.to_json
        end

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/users/two_factor_settings/create')
        end
      end
    end

    describe 'DELETE /api/v1/user/two_factor_settings' do
      context 'with account_verified pending for validation' do
        before do
          delete two_factor_settings_path, headers: auth_headers(user)
        end

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/users/two_factor_settings/destroy')
        end
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') do
      let(:execute) do
        get new_two_factor_settings_path, headers: headers
      end
    end

    it_behaves_like('having an authentication error') do
      let(:execute) do
        post two_factor_settings_path, headers: headers
      end
    end

    it_behaves_like('having an authentication error') do
      let(:execute) do
        delete two_factor_settings_path, headers: headers
      end
    end
  end

  context 'with a disabled account' do
    let(:user) { create(:user, active: false) }

    it_behaves_like('being a disabled user') do
      let(:execute) do
        get new_two_factor_settings_path, headers: auth_headers(user)
      end
    end

    it_behaves_like('being a disabled user') do
      let(:execute) do
        post two_factor_settings_path, headers: auth_headers(user)
      end
    end

    it_behaves_like('being a disabled user') do
      let(:execute) do
        delete two_factor_settings_path, headers: auth_headers(user)
      end
    end
  end
end
