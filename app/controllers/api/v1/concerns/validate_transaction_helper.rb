module Api::V1::Concerns::ValidateTransactionHelper
  def auth_params
    params.require(:user).permit(:password)
  end

  def available_to_execute?
    return valid_to_execute? if auth_params[:password].present?

    true
  end

  def valid_to_execute?
    current_user.valid_password?(auth_params[:password])
  end
end
