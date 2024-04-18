class Api::V1::ApiController < ActionController::API
  include Api::V1::Concerns::ApiResponses
  include Api::V1::Concerns::ExceptionHandler

  before_action :authenticate_user!
  before_action :check_user_activity
  before_action :app_version_supported?
  after_action -> { request.session_options[:skip] = true }

  def app_version_supported?
    return true if Rails.env.test? # dont check this for the test cases.
    if current_user.present? && current_user.device.present? && current_user.device.force_update?
      json_error_response('Update required! Please update Minnect to the latest version of the app', :bad_request)
      #SendForceUpdateNotification.call(current_user.device, current_user)
    else
      true
    end
  end

  private

  def check_user_activity
    json_error_response('This account has been deactivated', :unauthorized) unless current_user.active?
  end

  def check_valid_call_duration
    call_duration_param = params.permit(:call_duration).to_hash
    validate_call_duration = AvailabilityContract.new.call(call_duration_param)
    return unless validate_call_duration.failure?

    error = "Call duration #{validate_call_duration.errors.to_hash[:call_duration].join(', ')}"
    json_error_response(error)
  end
end
