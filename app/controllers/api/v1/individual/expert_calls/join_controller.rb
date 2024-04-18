class Api::V1::Individual::ExpertCalls::JoinController <
      Api::V1::Individual::ExpertCallsController
  def create
    @expert_call = @individual.expert_calls.find_by(id: params[:id])
    @expert_call ||= @individual.guest_in_calls.find_by!(expert_call_id: params[:id]).expert_call
    @token = TwilioServices::CreateAccessToken.call(
      @expert_call.room_id, @individual.id
    )
    @time_left = @expert_call.call_time + time_additions - ExpertCalls::CallDuration.new(@expert_call).call
  end

  private

  def time_additions
    return 0 unless @expert_call.time_additions.confirmed.present?

    @expert_call.time_additions.confirmed.sum(&:duration)
  end
end
