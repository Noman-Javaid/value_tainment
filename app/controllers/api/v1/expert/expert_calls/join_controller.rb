class Api::V1::Expert::ExpertCalls::JoinController <
      Api::V1::Expert::ExpertCallsController
  before_action :set_expert_call, only: %i[create]

  def create
    @token = TwilioServices::CreateAccessToken.call(
      @expert_call.room_id, @expert_call.expert.id
    )
    @time_left = @expert_call.call_time + time_additions - ExpertCalls::CallDuration.new(@expert_call).call
  end

  private
  def time_additions
    return 0 unless @expert_call.time_additions.confirmed.present?

    @expert_call.time_additions.confirmed.sum(&:duration)
  end
end
