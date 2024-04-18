class ExpertCalls::CallDuration
  def initialize(expert_call)
    @expert_call = expert_call
  end

  # return total call duration in seconds
  def call
    total_call_duration = disconection_events.sum(&:duration)
    if total_call_duration.zero?
      total_call_duration =
        if last_connection_event
          expert_recent_activity_time
        else
          0
        end
    elsif expert_in_call?
      total_call_duration = expert_recent_activity_time + total_call_duration
    end
    total_call_duration.to_i
  end

  def expert_in_call?
    return false unless last_connection_event

    @expert_in_call ||= last_connection_event.event_datetime > disconection_events.last.event_datetime
  end

  # recent activity time in seconds if expert has not left the call
  def expert_recent_activity_time
    @expert_recent_activity_time ||= Time.current - last_connection_event.event_datetime
  end

  # expert recent inactivity time in seconds if expert leaves call
  def expert_recent_inactivity_time
    return 0 if expert_in_call?

    Time.current - disconection_events.last.event_datetime
  end

  def disconection_events
    @disconection_events ||= @expert_call.participant_events.experts.disconnected
  end

  def last_connection_event
    @last_connection_event ||= @expert_call.participant_events.experts.connected.last
  end
end
