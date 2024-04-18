require 'rails_helper'

RSpec.describe 'Api::V1::User::Devices::DevicesController', type: :request do
  let(:create_device_path) { api_v1_user_devices_path }
  let(:user) { create(:user, :with_profile) }

  context 'with valid authentication and authorization data' do
    before do
      put create_device_path, headers: auth_headers(user),
                              params: { device: { token: 'fake_token' } }.to_json
    end

    describe 'PUT /api/v1/user/devices' do
      it_behaves_like 'success JSON response'

      it 'matches the expected schema' do
        expect(response).to match_json_schema('v1/devices/update')
      end
    end
  end

  context 'with authentication errors' do
    describe 'PUT /api/v1/users/devices' do
      it_behaves_like('having an authentication error') { let(:execute) { put create_device_path, headers: headers } }
    end
  end

  context 'with a disabled account' do
    let(:inactive_user) { create(:user, active: false) }
    let(:aux_headers) { Devise::JWT::TestHelpers.auth_headers({ 'Accept' => 'application/json' }, inactive_user) }

    # rubocop:todo RSpec/RepeatedExampleGroupDescription
    describe 'PUT /api/v1/users/devices' do # rubocop:todo RSpec/RepeatedExampleGroupBody
      it_behaves_like('being a disabled user') { let(:execute) { put create_device_path, headers: auth_headers(inactive_user), params: {} } }
    end
    # rubocop:enable RSpec/RepeatedExampleGroupDescription

    # rubocop:todo RSpec/RepeatedExampleGroupDescription
    describe 'PUT /api/v1/users/devices' do # rubocop:todo RSpec/RepeatedExampleGroupBody
      it_behaves_like('being a disabled user') { let(:execute) { put create_device_path, headers: auth_headers(inactive_user), params: {} } }
    end
    # rubocop:enable RSpec/RepeatedExampleGroupDescription
  end
end
