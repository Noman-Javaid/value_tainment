require 'rails_helper'

RSpec.describe 'Api::V1::EmailConfirmationController', type: :request do
  let(:user) { create(:user) }
  let(:email) { user.email }
  let(:email_confirmation_path) { api_v1_email_confirmation_path }

  describe 'POST /email_confirmation/' do
    context 'with a valid registered email' do
      include_context 'Aws mocks and stubs'

      before do
        user.update!(confirmed_at: nil)
        post email_confirmation_path, params: { email: email }
      end

      it_behaves_like 'success JSON response'

      it 'matches the expected schema' do
        expect(response).to match_json_schema('v1/email_confirmation/send_instructions')
      end

      it 'email_verification_sent field is true' do
        expect(json['data']['email_confirmation_sent']).to be_truthy
      end
    end

    context 'with an email that has already been confirmed' do
      before do
        user.update!(confirmed_at: DateTime.now)
        post email_confirmation_path, params: { email: email }
      end

      it_behaves_like 'error JSON response', :bad_request

      it 'matches with the error message' do
        expect(json['message']).to eq('This account has already been confirmed')
      end
    end

    context 'with an invalid email' do
      before do
        user.destroy
        post email_confirmation_path, params: { email: email }
      end

      it_behaves_like 'error JSON response', :not_found

      it 'matches with the error message' do
        expect(json['message']).to eq('Record Not Found')
      end
    end

    context 'without email param' do
      before do
        post email_confirmation_path, params: { email_confirmation: email }
      end

      it_behaves_like 'error JSON response', :bad_request

      it 'matches with the error message' do
        expect(json['message']).to eq('Invalid parameters')
      end
    end
  end
end
