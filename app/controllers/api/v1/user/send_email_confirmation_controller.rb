class Api::V1::User::SendEmailConfirmationController < Api::V1::UsersController
  # send email for account verifcation to existing user
  def show
    return json_error_response('This account has already been confirmed') if current_user.account_verified?

    current_user.send_confirmation_instructions
    render 'api/v1/email_confirmation/send_instructions'
  end
end
