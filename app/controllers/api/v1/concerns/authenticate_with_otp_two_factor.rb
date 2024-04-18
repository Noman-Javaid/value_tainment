module Api::V1::Concerns::AuthenticateWithOtpTwoFactor
  extend ActiveSupport::Concern

  AUTH_CODE_MISSING_2FA_CODE = 'auth-001'.freeze
  AUTH_CODE_INVALID_2FA_CODE = 'auth-002'.freeze

  def authenticate_with_otp_two_factor
    self.resource = user
    return unless user.valid_password?(user_params[:password])

    if user_params[:two_factor_code].nil?
      message = TwilioServices::SendTwoFactorCodeBySms.new(user).call
      return json_error_response(message.error, :service_unavailable) if message.respond_to?(:error)

      json_error_response(
        'Two factor code is required.',
        :unauthorized,
        {
          error_code: AUTH_CODE_MISSING_2FA_CODE,
          code_sent_to: user_phone_last_four_numbers
        }
      )
    else
      authenticate_user_with_otp_two_factor
    end
  end

  private

  def valid_two_factor_code?
    user.validate_and_consume_otp!(user_params[:two_factor_code]) ||
      user.validate_otp_backup_code(user_params[:two_factor_code])
  end

  def authenticate_user_with_otp_two_factor
    unless valid_two_factor_code?
      return json_error_response(
        'Invalid code',
        :unauthorized,
        {
          error_code: AUTH_CODE_INVALID_2FA_CODE,
          code_sent_to: user_phone_last_four_numbers
        }
      )
    end

    user.change_current_role! if available_to_change_profile?(user)
    sign_in(@user, event: :authentication)
    request.session_options[:skip] = true
    render 'api/v1/auth/sessions/create'
  end

  def user_params
    params.require(:user).permit(
      :email, :password, :role, :two_factor_code
    )
  end

  def user
    @user ||= User.find_by(email: user_params[:email])
  end

  def otp_two_factor_enabled?
    user&.otp_required_for_login
  end

  def user_phone_last_four_numbers
    return nil unless user.phone_number

    user.phone_number.last(4)
  end
end
