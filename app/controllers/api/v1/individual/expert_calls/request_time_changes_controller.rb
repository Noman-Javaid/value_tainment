class Api::V1::Individual::ExpertCalls::RequestTimeChangesController < Api::V1::Individual::ExpertCallsController
  before_action :set_expert_call, only: %i[accept decline]
  before_action :set_time_change_request, only: %i[accept decline]

  def accept
    accept_time_change_request = Individual::Calls::AcceptTimeChangeRequest.call(@individual, @expert_call, @time_change_request)
    if accept_time_change_request.success?
      render json: { success: true, message: I18n.t('api.expert_call.change_time.accepted') }
    else
      json_error_response(accept_time_change_request.errors[:error_message].join(','), :internal_server_error)
    end
  end

  def decline
    decline_time_change_request = Individual::Calls::DeclineTimeChangeRequest.call(@individual, @expert_call, @time_change_request)
    if decline_time_change_request.success?
      render json: { success: true, message: I18n.t('api.expert_call.change_time.declined') }
    else
      json_error_response(decline_time_change_request.errors[:error_message].join(','), :internal_server_error)
    end
  end

  private

  def set_expert_call
    @expert_call = @individual.expert_calls.find(params[:expert_call_id])
  end

  def set_time_change_request
    @time_change_request = @expert_call.time_change_requests.find(params[:time_change_request_id])
  end
end
