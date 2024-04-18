require 'rails_helper'

RSpec.describe 'Api::V1::User::AllowNotificationsController', type: :request do
  let(:allow_notifications_path) { api_v1_user_allow_notifications_path }
  let(:user) { create(:user, :with_profile) }
  let(:user_data) { { user: { allow_notifications: true } } }

  context 'with valid authentication and authorization data' do
    describe 'PATCH /api/v1/user/allow_notifications' do
      context 'with turn on notifications for the user' do
        before do
          user.update!(allow_notifications: false)
          patch allow_notifications_path, headers: auth_headers(user),
                                          params: user_data.to_json
        end

        it_behaves_like 'success JSON response'

        it 'has allow_notifications changed' do
          expect { user.reload }.to change(user, :allow_notifications)
        end
      end

      context 'with turn off notifications for the user' do
        let(:user_data) { { user: { allow_notifications: false } } }

        before do
          user.update!(allow_notifications: true)
          patch allow_notifications_path, headers: auth_headers(user),
                                          params: user_data.to_json
        end

        it_behaves_like 'success JSON response'

        it 'has allow_notifications changed' do
          expect { user.reload }.to change(user, :allow_notifications)
        end
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') do
      let(:execute) do
        patch allow_notifications_path, headers: headers
      end
    end
  end

  context 'with a disabled account' do
    let(:user) { create(:user, active: false) }
    let(:user_data) { { user: { allow_notifications: 'some value' } } }

    it_behaves_like('being a disabled user') do
      let(:execute) do
        patch allow_notifications_path,
              headers: auth_headers(user),
              params: user_data.to_json
      end
    end
  end
end
