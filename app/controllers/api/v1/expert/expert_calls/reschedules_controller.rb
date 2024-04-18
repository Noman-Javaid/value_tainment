class Api::V1::Expert::ExpertCalls::ReschedulesController < Api::V1::Expert::ExpertCallsController
  before_action :set_expert_call, only: %i[create accept decline]
  before_action :set_rescheduling_request, only: %i[accept decline]

  def create
    reschedule_request = Expert::Calls::Reschedule.call(@expert, @expert_call, reschedule_params)
    if reschedule_request.success?
      render json: { success: true, message: I18n.t('api.expert_call.rescheduling.created') }
    else
      json_error_response(reschedule_request.errors[:error_message].join(','), :internal_server_error)
    end
  end

  def decline
    decline_reschedule_request = Expert::Calls::DeclineReschedulingRequest.call(@expert, @expert_call, @rescheduling_request)
    if decline_reschedule_request.success?
      render json: { success: true, message: I18n.t('api.expert_call.rescheduling.accepted') }
    else
      json_error_response(decline_reschedule_request.errors[:error_message].join(','), :internal_server_error)
    end
  end

  def accept
    accept_reschedule_request = Expert::Calls::AcceptReschedulingRequest.call(@expert, @expert_call, @rescheduling_request)
    if accept_reschedule_request.success?
      render json: { success: true, message: I18n.t('api.expert_call.rescheduling.accepted') }
    else
      json_error_response(accept_reschedule_request.errors[:error_message].join(','), :internal_server_error)
    end
  end

  private

  def reschedule_params
    params.require(:expert_call).permit(:new_requested_start_time, :rescheduling_reason)
  end

  def set_expert_call
    @expert_call = @expert.expert_calls.find(params[:expert_call_id])
  end

  def set_rescheduling_request
    @rescheduling_request = @expert_call.rescheduling_requests.find(params[:rescheduling_request_id])
  end

end
