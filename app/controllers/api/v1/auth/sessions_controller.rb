class Api::V1::Auth::SessionsController < Devise::SessionsController
  include Api::V1::Concerns::ApiResponses
  include Api::V1::Concerns::ExceptionHandler
  include Api::V1::Concerns::AuthenticateWithOtpTwoFactor

  # FIXME: This shouldn't be necessary due to routing namespaces.
  # However it was needed in order to avoid a ActionController::UnknownFormat.
  respond_to :json
  prepend_before_action :authenticate_with_otp_two_factor,
                        if: -> { action_name == 'create' && otp_two_factor_enabled? }
  prepend_before_action :verify_signed_out_user, only: :destroy # rubocop:todo Rails/LexicallyScopedActionFilter
  after_action -> { request.session_options[:skip] = true }

  skip_before_action :verify_authenticity_token

  def create
    super do |resource|
      resource.change_current_role! if available_to_change_profile?(resource)
    end
  end

  def auth_options
    { scope: :user, recall: 'api/v1/auth/sessions#new' }
  end

  def self.custom_message(failure)
    failure.fetch_message(:not_found_in_database) if failure.current_message.nil?
  end

  private

  def available_to_change_profile?(resource)
    resource.both_profiles? && User.valid_role?(sign_in_params[:role]) &&
      resource.logued_with_role != sign_in_params[:role]
  end

  def sign_in_params
    params.require(:user).permit(:role)
  end

  def verify_signed_out_user
    respond_to_on_destroy if all_signed_out?
  end

  def respond_to_on_destroy
    render json: { status: 'success', data: nil }, status: :ok
  end
end
