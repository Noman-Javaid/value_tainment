require 'rails_helper'

RSpec.describe 'Api::V1::Auth::RegistrationsController', type: :request do
  subject { post sign_up_path, headers: headers, params: user_data.to_json }

  let(:user) { build(:user) }
  let(:sign_up_path) { api_v1_sign_up_path }

  include_context 'with JWT context'

  describe '/api/v1/sign_up' do
    context 'when the email is not already used' do
      context 'with valid user data' do
        let(:user_data) do
          {
            user: {
              email: user.email,
              password: user.password,
              password_confirmation: user.password,
              first_name: user.first_name,
              last_name: user.last_name,
              role: user.role # individual by default in the factory
            }
          }
        end

        before { subject } # rubocop:todo RSpec/NamedSubject

        it_behaves_like 'success JSON response'
        it_behaves_like 'user JSON response'

        it 'returns a valid JWT token as a response header' do
          expect(response.headers['Authorization']).to include('Bearer ')
        end
      end

      context 'when the account needs to be confirmed by the user before login' do
        let(:user_data) do
          {
            user: {
              email: user.email,
              password: user.password,
              password_confirmation: user.password,
              first_name: user.first_name,
              last_name: user.last_name,
              role: user.role,
              requires_confirmation: true
            }
          }
        end

        context 'when user gets registerd' do
          it 'sends email to user' do
            expect { subject }.to change { ActionMailer::Base.deliveries.size }.by(1) # rubocop:todo RSpec/NamedSubject
          end
        end

        context 'with proper response' do
          before { subject } # rubocop:todo RSpec/NamedSubject

          it_behaves_like 'success JSON response'

          it 'does not returns a JWT token as a response header' do
            expect(response.headers['Authorization']).to be_nil
          end
        end
      end

      context 'without the optional password confirmation' do
        let(:user_data) do
          {
            user: {
              email: user.email,
              password: user.password,
              password_confirmation: nil,
              first_name: user.first_name,
              last_name: user.last_name,
              role: user.role
            }
          }
        end

        before { subject } # rubocop:todo RSpec/NamedSubject

        it_behaves_like 'fail JSON response', :unprocessable_entity
      end

      context 'when the role is "expert"' do
        let(:user) { build(:user, :expert) }
        let(:created_user) { User.find_by(email: user.email) }
        let(:user_data) do
          {
            user: {
              email: user.email,
              password: user.password,
              password_confirmation: user.password,
              first_name: user.first_name,
              last_name: user.last_name,
              role: user.role
            }
          }
        end

        before { subject } # rubocop:todo RSpec/NamedSubject

        it_behaves_like 'success JSON response'
        it_behaves_like 'user JSON response'

        it 'returns an expert object' do
          expect(json['data']['user']).to include('expert')
        end

        it 'returns an expert object with correct structure and data' do
          expect(json['data']['user']['expert']).to include(
            {
              'status' => created_user.expert.status
            }
          )
        end
      end

      context 'when the role is "individual"' do
        let(:user) { build(:user, :individual) }
        let(:created_user) { User.find_by(email: user.email) }
        let(:user_data) do
          {
            user: {
              email: user.email,
              password: user.password,
              password_confirmation: user.password,
              first_name: user.first_name,
              last_name: user.last_name,
              role: user.role
            }
          }
        end

        before { subject } # rubocop:todo RSpec/NamedSubject

        it_behaves_like 'success JSON response'
        it_behaves_like 'user JSON response'

        it 'returns an individual object' do
          expect(json['data']['user']).to include('individual')
        end

        it 'returns an individual object with correct structure and data' do
          expect(json['data']['user']['individual']).to include(
            {
              'has_stripe_payment_method' => created_user.individual.has_stripe_payment_method
            }
          )
        end
      end

      context 'without a password, email, first name and last name' do
        let(:user_data) { { user: {} } }

        before { subject } # rubocop:todo RSpec/NamedSubject

        it_behaves_like 'error JSON response', :bad_request

        it 'returns the correct error data' do
          expect(json['message']).to eq('Invalid parameters')
        end
      end

      context 'with blank password, email, first name, last name and role' do
        let(:user_data) do
          {
            user: {
              email: '',
              password: '',
              password_confirmation: '',
              first_name: '',
              last_name: '',
              role: ''
            }
          }
        end

        before { subject } # rubocop:todo RSpec/NamedSubject

        it_behaves_like 'fail JSON response', :unprocessable_entity

        it 'returns the correct error data' do
          expect(json['message']).to eq("Email can't be blank, Password can't be blank, First name can't be blank, Last name can't be blank, Role must be provided with value \"expert\" or \"individual\", Password confirmation can't be blank")
        end
      end

      context 'with a password confirmation different from the password' do
        let(:user_data) { { user: { email: user.email, password: user.password, password_confirmation: "#{user.password}-" } } }

        before { subject } # rubocop:todo RSpec/NamedSubject

        it_behaves_like 'fail JSON response', :unprocessable_entity

        it 'returns the correct error data' do
          expect(json['message']).to eq("Password confirmation doesn't match Password, First name can't be blank, Last name can't be blank, Role must be provided with value \"expert\" or \"individual\"")
        end
      end

      context 'without any data' do
        let(:user_data) { { user: nil } }

        before { subject } # rubocop:todo RSpec/NamedSubject

        it_behaves_like 'error JSON response', :bad_request

        it 'returns the correct error data' do
          expect(json['message']).to eq('Invalid parameters')
        end
      end
    end

    context 'when the email is already used' do
      let(:user_data) { { user: { email: user.email, password: user.password, password_confirmation: user.password } } }

      before do
        create(:user, email: user.email)
        subject # rubocop:todo RSpec/NamedSubject
      end

      it_behaves_like 'fail JSON response', :unprocessable_entity

      it 'returns the correct error data' do
        expect(json['message']).to eq("Email has already been taken, First name can't be blank, Last name can't be blank, Role must be provided with value \"expert\" or \"individual\"")
      end
    end
  end
end