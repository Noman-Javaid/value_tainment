class Api::V1::Expert::ExpertCalls::RequestTimeChangesController < Api::V1::Expert::ExpertCallsController
  before_action :set_expert_call, only: %i[create]

  def create
    time_change_request = Expert::Calls::RequestTimeChange.call(@expert, @expert_call, time_change_request_params)
    if time_change_request.success?
      render json: { success: true, message: I18n.t('api.expert_call.change_time.created') }
    else
      json_error_response(time_change_request.errors[:error_message].join(','), :internal_server_error)
    end
  end

  private

  def time_change_request_params
    params.require(:expert_call).permit(:new_suggested_start_time, :reason)
  end

  def set_expert_call
    @expert_call = @expert.expert_calls.find(params[:expert_call_id])
  end
end
