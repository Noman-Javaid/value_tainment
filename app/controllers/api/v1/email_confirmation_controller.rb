class Api::V1::EmailConfirmationController < Api::V1::ApiController
  skip_before_action :authenticate_user!
  skip_before_action :check_user_activity

  def send_instructions
    user = User.find_by!(email: confirmation_params[:email])
    return json_error_response('This account has already been confirmed') if user.confirmed?

    user.send_confirmation_instructions
  end

  private

  def confirmation_params
    params.required(:email)
    params.permit(:email)
  end
end
