require 'rails_helper'

RSpec.describe 'Api::V1::Auth::SessionsController', type: :request do
  let(:email) { 'user@user.com' }
  let(:password) { '123123123' }
  let(:sign_in_path) { api_v1_sign_in_path }
  let(:sign_out_path) { api_v1_sign_out_path }

  RSpec.shared_examples_for 'JSON sign_out response' do
    it 'returns a correct response' do
      expect(response).to have_http_status(:ok)
      expect(json['status']).to eq('success')
      expect(json['data']).to be_nil
    end
  end

  include_context 'with JWT context'

  describe '/api/v1/sign_in' do
    context 'with valid user data' do
      let(:user_data) { { user: { email: user.email, password: password, role: role } } }

      context 'with an existing user' do
        let!(:user) { create(:user, :with_profile, email: email, password: password) }
        let(:role) { 'individual' }

        before do
          user.regenerate_two_factor_secret!
        end

        context 'with two factor disabled' do
          before do
            post sign_in_path, headers: headers, params: user_data.to_json
          end

          it_behaves_like 'success JSON response'

          it 'matches the expected schema' do
            expect(response).to match_json_schema('v1/users/show')
          end

          it 'returns a valid JWT token as a response header' do
            expect(response.headers['Authorization']).to include('Bearer ')
          end
        end

        context 'with two factor enable and two factor code is not sent' do
          include_context 'with Twilio mocks and stubs'
          let(:user_phone_last_four) { user.phone_number.last(4) }
          let(:auth_error_code) do
            Api::V1::Concerns::AuthenticateWithOtpTwoFactor::AUTH_CODE_MISSING_2FA_CODE
          end

          before do
            user.enable_two_factor!
            post sign_in_path, headers: headers, params: user_data.to_json
          end

          it_behaves_like 'error JSON response', :unauthorized

          it 'returns the correct error message' do
            expect(json['message']).to eq('Two factor code is required.')
          end

          it 'returns the correct error code' do
            expect(json['code']).to eq(auth_error_code)
          end

          it 'returns the correct error two_factor_code_sent_to' do
            expect(json['two_factor_code_sent_to']).to eq(user_phone_last_four)
          end
        end

        context 'with two factor enable and two factor code is sent' do
          include_context 'with Twilio mocks and stubs'

          let(:user_data) do
            {
              user: {
                email: user.email, password: password, role: role, two_factor_code: code
              }
            }
          end

          before do
            user.enable_two_factor!
          end

          context 'with otp as code' do
            let(:code) { user.current_otp }

            before do
              post sign_in_path, headers: headers, params: user_data.to_json
            end

            it_behaves_like 'success JSON response'

            it 'matches the expected schema' do
              expect(response).to match_json_schema('v1/users/show')
            end

            it 'returns a valid JWT token as a response header' do
              expect(response.headers['Authorization']).to include('Bearer ')
            end
          end

          context 'with backup code' do
            let(:code) do
              code = user.generate_otp_backup_codes!.first
              user.save
              code
            end

            before do
              post sign_in_path, headers: headers, params: user_data.to_json
            end

            it_behaves_like 'success JSON response'

            it 'matches the expected schema' do
              expect(response).to match_json_schema('v1/users/show')
            end

            it 'returns a valid JWT token as a response header' do
              expect(response.headers['Authorization']).to include('Bearer ')
            end
          end
        end
      end

      context 'with an existing user that has both profiles and role is specified' do
        include_context 'users_for_expert_endpoints'

        before do
          user.create_individual
          user.update!(password: password, password_confirmation: password)
        end

        context 'when user has current role as individual and role specified is expert' do
          let(:role) { 'expert' }

          before do
            user.update!(current_role: 'as_individual')
            post sign_in_path, headers: headers, params: user_data.to_json
            user.reload
          end

          it_behaves_like 'success JSON response'

          it 'change the user\'s current role to expert' do
            expect(user).to be_as_expert
          end

          it 'matches the expected schema' do
            expect(response).to match_json_schema('v1/users/show')
          end
        end

        context 'when user has current role as expert and role specified is individual' do
          let(:role) { 'individual' }

          before do
            user.update!(current_role: 'as_expert')
            post sign_in_path, headers: headers, params: user_data.to_json
            user.reload
          end

          it_behaves_like 'success JSON response'

          it 'change the user\'s current role to expert' do
            expect(user).to be_as_individual
          end

          it 'matches the expected schema' do
            expect(response).to match_json_schema('v1/users/show')
          end
        end

        context 'when user has current role as expert and role specified is invalid' do
          let(:role) { 'invalid' }

          before do
            user.update!(current_role: 'as_expert')
            post sign_in_path, headers: headers, params: user_data.to_json
            user.reload
          end

          it_behaves_like 'success JSON response'

          it 'does not change the user\'s current role' do
            expect(user).to be_as_expert
          end

          it 'matches the expected schema' do
            expect(response).to match_json_schema('v1/users/show')
          end
        end
      end

      context 'with a nonexisting user' do
        let(:user_data) { { user: { email: email, password: "#{password}-" } } }

        before do
          post sign_in_path, headers: headers, params: user_data.to_json
        end

        it_behaves_like 'error JSON response', :unauthorized

        it 'returns the correct error data' do
          expect(json['message']).to eq('Invalid Email or password.')
        end
      end
    end

    context 'with a valid email, but invalid password' do
      let!(:user) { create(:user, email: email, password: password) } # rubocop:todo RSpec/LetSetup
      let(:user_data) { { user: { email: email, password: "#{password}-" } } }

      before do
        post sign_in_path, headers: headers, params: user_data.to_json
      end

      it_behaves_like 'error JSON response', :unauthorized

      it 'returns the correct error data' do
        expect(json['message']).to eq('Invalid Email or password.')
      end
    end

    context 'with invalid user data' do
      before do
        post sign_in_path, headers: headers, params: user_data.to_json
      end

      context 'without a valid email, but invalid password' do
        let(:user_data) { { user: { email: email, password: "#{password}-" } } }

        it_behaves_like 'error JSON response', :unauthorized

        it 'returns the correct error data' do
          expect(json['message']).to eq('Invalid Email or password.')
        end
      end

      context 'without a password' do
        let(:user_data) { { user: { email: email } } }

        it_behaves_like 'error JSON response', :unauthorized

        it 'returns the correct error data' do
          expect(json['message']).to eq('Invalid Email or password.')
        end
      end

      context 'without an email' do
        let(:user_data) { { user: { password: password } } }

        it_behaves_like 'error JSON response', :unauthorized

        it 'returns the correct error data' do
          expect(json['message']).to eq('Invalid Email or password.')
        end
      end

      context 'without any data' do
        let(:user_data) { { user: nil } }

        it_behaves_like 'error JSON response', :bad_request

        it 'returns the correct error data' do
          expect(json['message']).to eq('Invalid parameters')
        end
      end
    end
  end

  describe '/api/v1/sign_out' do
    let(:user) { create(:user, password: password) }
    let(:user_data) { { user: { email: user.email, password: password } } }
    let(:current_auth_headers) { auth_headers(user) }

    context 'with valid token' do
      before do
        delete sign_out_path, headers: current_auth_headers
      end

      it_behaves_like 'JSON sign_out response'

      it 'has revoked the token' do
        get api_v1_user_path, headers: current_auth_headers

        expect(json['message']).to eq('revoked token')
      end
    end

    context 'with invalid token' do
      before do
        current_auth_headers['Authorization'] = 'xxx'
        delete sign_out_path, headers: current_auth_headers
      end

      it_behaves_like 'JSON sign_out response'

      it 'returns the correct error data when trying to access an authenticated endpoint' do
        get api_v1_user_path, headers: current_auth_headers

        expect(json).to include('status', 'message')
        expect(response).to have_http_status(:unauthorized)
        expect(response.content_type).to include('application/json')
        expect(json['status']).to eq('error')
        expect(json['message']).to eq('You need to sign in or sign up before continuing.')
      end
    end
  end
end
