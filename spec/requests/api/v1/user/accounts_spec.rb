require 'rails_helper'

RSpec.describe 'Api::V1::Expert:: DeleteAccountsController', type: :request do
  let(:delete_account_path) { api_v1_user_accounts_path }
  let(:user_password) { '321321321' }
  let(:user_account_deletion_job) { Users::AccountDeletionJob }

  context 'with valid authentication and authorization data' do
    include_context 'users_for_individual_endpoints'
    describe 'DELETE /api/v1/user/accounts' do
      subject { delete delete_account_path, headers: auth_headers(user), params: params }

      before { subject } # rubocop:todo RSpec/NamedSubject

      context 'when user provide a valid password' do
        let(:params) { { user: { password: user_password } }.to_json }

        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/accounts/destroy')
        end

        it 'user is pending to delete' do
          expect(user.reload).to be_pending_to_delete
        end

        it 'user is inactive' do
          expect(user.reload).not_to be_active
        end

        it 'user account_deletion_requested_at is not nil' do
          expect(user.reload.account_deletion_requested_at).not_to be_nil
        end

        it 'account deletion service was called' do
          expect(user_account_deletion_job).to have_been_enqueued.with(user)
        end
      end

      context 'when user provide an invalid password' do
        let(:params) { { user: { password: "#{user_password}1" } }.to_json }

        it_behaves_like 'error JSON response', :bad_request

        it 'matches with the error message' do
          expect(json['message']).to eq('Invalid Password')
        end
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') do
      let(:execute) { delete delete_account_path, headers: headers }
    end
  end

  context 'with a disabled account' do
    let(:user) { create(:user, :individual, active: false) }

    it_behaves_like('being a disabled user') do
      let(:execute) { delete delete_account_path, headers: auth_headers(user) }
    end
  end
end
