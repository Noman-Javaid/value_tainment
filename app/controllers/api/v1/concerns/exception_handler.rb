module Api::V1::Concerns::ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |_error|
      json_error_response('Record Not Found', :not_found)
    end

    rescue_from ActiveRecord::RecordNotUnique,
                ActiveRecord::RecordNotDestroyed do |_error|
      json_error_response('Invalid Operation', :unprocessable_entity)
    end

    rescue_from ActiveRecord::RecordInvalid, Stripe::StripeError do |error|
      json_error_response(error_data(error), :unprocessable_entity)
    end

    rescue_from Stripe::APIConnectionError do |_error|
      json_error_response('Payment service unavailable', :service_unavailable)
    end

    rescue_from ActionController::ParameterMissing do
      json_error_response('Invalid parameters', :bad_request)
    end

    rescue_from AASM::InvalidTransition do |error|
      json_error_response(transition_error_message(error), :unprocessable_entity)
    end

    # TODO: Check how to rescue from a 400 Bad Request
    # rescue_from ActionController::BadRequest do |e|
    #   json_error_response(e.message, :bad_request)
    # end
  end

  private

  def error_data(error)
    error.respond_to?(:record) ? error.record.errors.full_messages.join(', ') : error.message
  end

  def transition_error_message(error)
    return inactive_user_message if error.failures.include?(:both_users_are_active?)

    invalid_transition_message
  end

  def inactive_user_message
    'The resource could not be updated because the other User has an inactive account'
  end

  def invalid_transition_message
    'The previous action could not be completed'
  end
end
