class ExpertCalls::CallFinisher
  def initialize(expert_call)
    @expert_call = expert_call
  end

  def call
    return unless @expert_call.ongoing?

    room = TwilioServices::EndExpertCall.new(@expert_call.room_id).call
    if @expert_call.participant_events.where(expert: true, initial: true).first
      @expert_call.finish
    else
      @expert_call.set_as_incompleted
    end
    @expert_call.update!(call_time: room.duration, time_end: room.end_time)
  end
end
