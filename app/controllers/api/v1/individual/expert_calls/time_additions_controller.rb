class Api::V1::Individual::ExpertCalls::TimeAdditionsController <
      Api::V1::Individual::ExpertCallsController
  before_action :set_expert_call, only: %i[create]

  def create
    @time_addition = @expert_call.time_additions.create!(time_addition_params)
    Notifications::Experts::ExpertCalls::TimeAdditionRequestNotifier.new(@time_addition)
                                                                    .execute
  end

  private

  def set_expert_call
    @expert_call = @individual.expert_calls.find(params[:expert_call_id])
  end

  def time_addition_params
    params.require(:time_addition).permit(:duration) if params[:time_addition]&.dig(:duration)
  end
end
