class Api::V1::User::AccountsController < Api::V1::UsersController
  include Api::V1::Concerns::ValidateTransactionHelper

  def destroy
    return json_error_response('Invalid Password', :bad_request) unless valid_to_execute?

    current_user.update!(
      active: false, pending_to_delete: true, account_deletion_requested_at: Time.current
    )
    Users::AccountDeletionJob.perform_later(current_user)
    render 'api/v1/users/accounts/destroy'
  end
end
