require 'rails_helper'

RSpec.describe 'Api::V1::User::SendEmailConfirmationController', type: :request do
  let(:send_email_confirmation_path) { api_v1_user_send_email_confirmation_path }
  let(:user) { create(:user, :with_profile) }

  context 'with valid authentication and authorization data' do
    describe 'GET /api/v1/user/send_email_confirmation' do
      context 'with account_verified pending for validation' do
        include_context 'Aws mocks and stubs'

        before do
          get send_email_confirmation_path, headers: auth_headers(user)
        end

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/email_confirmation/send_instructions')
        end

        it 'has an email_verification_sent field in response' do
          expect(json['data']['email_confirmation_sent']).to be_present
        end
      end

      context 'with account_verified already validated' do
        before do
          user.update!(account_verified: true)
          get send_email_confirmation_path, headers: auth_headers(user)
        end

        it_behaves_like 'error JSON response', :bad_request

        it 'match with the eror message' do
          expect(json['message']).to eq('This account has already been confirmed')
        end
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') do
      let(:execute) do
        get send_email_confirmation_path, headers: headers
      end
    end
  end

  context 'with a disabled account' do
    let(:user) { create(:user, active: false) }

    it_behaves_like('being a disabled user') do
      let(:execute) do
        get send_email_confirmation_path, headers: auth_headers(user)
      end
    end
  end
end
