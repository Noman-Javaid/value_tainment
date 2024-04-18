class Api::V1::Expert::ExpertCalls::FinishCallsController <
  Api::V1::Expert::ExpertCallsController
  before_action :set_expert_call, only: %i[update]

  def update
    ExpertCalls::CallFinisher.new(@expert_call).call
    render 'api/v1/individual/expert_calls/create'
  end
end
