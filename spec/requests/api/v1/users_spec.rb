require 'rails_helper'

RSpec.describe 'Api::V1::UsersController', type: :request do
  let(:users_path) { api_v1_user_path }

  context 'with valid authentication and authorization data' do
    describe 'GET /user' do
      before do
        get users_path, headers: auth_headers(user)
      end

      context 'when the role is "expert"' do
        let(:user) { create(:user, :expert) }

        it_behaves_like 'success JSON response'
        it_behaves_like 'user JSON response'

        it 'returns an expert object' do
          expect(json['data']['user']).to include('expert')
        end

        it 'returns an expert object with correct structure and data' do
          expect(json['data']['user']['expert']).to include(
            {
              'status' => user.expert.status
            }
          )
        end
      end

      context 'when the role is "individual"' do
        let(:user) { create(:user, :individual) }

        it_behaves_like 'success JSON response'
        it_behaves_like 'user JSON response'

        it 'returns an individual object' do
          expect(json['data']['user']).to include('individual')
        end

        it 'returns an individual object with correct structure and data' do
          expect(json['data']['user']['individual']).to include(
            {
              'has_stripe_payment_method' => user.individual.has_stripe_payment_method
            }
          )
        end
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') { let(:execute) { get users_path, headers: headers } }
  end

  context 'with a disabled account' do
    let(:user) { create(:user, active: false) }

    it_behaves_like('being a disabled user') { let(:execute) { get users_path, headers: auth_headers(user) } }
  end
end
