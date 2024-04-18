class Api::V1::Individual::ExpertCalls::CancelsController < Api::V1::Individual::ExpertCallsController
  before_action :set_expert_call, only: %i[update]

  def update
    cancel_call = Individual::Calls::Cancel.call(@individual, @expert_call, cancellation_params[:cancellation_reason])
    if cancel_call.success?
      render json: { success: true, message: I18n.t('api.expert_call.cancellation.success') }
    else
      json_error_response(cancel_call.errors[:error_message].join(','), :internal_server_error)
    end
  end

  private

  def cancellation_params
    params.require(:expert_call).permit(:cancellation_reason)
  end

  def set_expert_call
    @expert_call = @individual.expert_calls.find(params[:expert_call_id])
  end
end
