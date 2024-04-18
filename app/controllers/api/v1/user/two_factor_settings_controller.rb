class Api::V1::User::TwoFactorSettingsController < Api::V1::UsersController
  before_action :set_user

  def new
    return json_error_response('Two factor authentication is already enabled') if @user.otp_required_for_login?

    @user.regenerate_two_factor_secret!
    message = TwilioServices::SendTwoFactorCodeBySms.new(@user).call
    return json_error_response(message.error, :service_unavailable) if message.respond_to?(:error)

    render '/api/v1/users/two_factor_settings/new'
  rescue ArgumentError => e
    Honeybadger.notify(e)
    json_error_response(e, :unprocessable_entity)
  end

  def create
    if @user.validate_and_consume_otp!(enable_2fa_params[:code])
      @user.phone_number_verified = true
      @backup_code = @user.generate_otp_backup_codes!.first
      @user.enable_two_factor!
      render '/api/v1/users/two_factor_settings/create'
    else
      json_error_response('Invalid code', :bad_request)
    end
  end

  def destroy
    @user.disable_two_factor!
    render '/api/v1/users/two_factor_settings/destroy'
  end

  private

  def enable_2fa_params
    params.require(:two_factor_settings).permit(:code)
  end

  def set_user
    @user = current_user
  end
end
