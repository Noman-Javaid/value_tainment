class ExpertCalls::CloseOngoingCall
  def initialize(expert_call)
    @expert_call = expert_call
  end

  def call
    @expert_call_duration = ExpertCalls::CallDuration.new(@expert_call)
    @expert_time_in_call = @expert_call_duration.call
    # if expert didn't join the call but call not over
    return if @expert_time_in_call.zero? && Time.current < @expert_call.scheduled_time_end

    if expert_is_absent_and_waiting_longer_than_call_duration? ||
       expert_stayed_longer_than_call_duration? || expert_left_and_did_not_rejoin_call?
      ExpertCalls::CallFinisher.new(@expert_call).call
    end
  end

  private

  # time left to complete call duration in seconds
  def call_time_left
    @call_time_left ||= @expert_call.call_time - @expert_time_in_call
  end

  def expert_is_absent_and_waiting_longer_than_call_duration?
    @expert_time_in_call.zero? && Time.current >= @expert_call.scheduled_time_end
  end

  # if the expert has been in the call longer than expected call duration
  def expert_stayed_longer_than_call_duration?
    @expert_time_in_call >= @expert_call.call_time
  end

  # if the expert join the call but never rejoin the call
  def expert_left_and_did_not_rejoin_call?
    @expert_call_duration.expert_recent_inactivity_time >= call_time_left
  end
end
