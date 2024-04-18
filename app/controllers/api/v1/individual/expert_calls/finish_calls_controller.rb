class Api::V1::Individual::ExpertCalls::FinishCallsController <
      Api::V1::Individual::ExpertCallsController
  def update
    @expert_call = @individual.expert_calls.find_by(id: params[:id])
    @expert_call ||= @individual.expert_calls_as_guest
                                .find(params[:id])
    ExpertCalls::CallFinisher.new(@expert_call).call
    render 'api/v1/individual/expert_calls/create'
  end
end
