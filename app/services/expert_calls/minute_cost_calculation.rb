class ExpertCalls::MinuteCostCalculation
  def initialize(expert_call)
    @expert_call = expert_call
  end

  def call
    if one_to_five_and_extra_users?
      extra_users_minute_rate
    elsif one_to_five_and_max_guests?
      expert.one_to_five_video_call_rate
    else
      expert.video_call_rate
    end
  end

  private

  def extra_users?
    guests_number > ExpertCall::MAX_GUESTS_NUMBER
  end

  def extra_users_minute_rate
    (((guests_number - ExpertCall::MAX_GUESTS_NUMBER) *
      expert.extra_user_rate) +
      expert.one_to_five_video_call_rate)
  end

  def one_to_five_and_extra_users?
    @expert_call.call_type == ExpertCall::CALL_TYPE_ONE_TO_FIVE && extra_users?
  end

  def one_to_five_and_max_guests?
    @expert_call.call_type == ExpertCall::CALL_TYPE_ONE_TO_FIVE &&
      guests_number >= 1 && guests_number <= ExpertCall::MAX_GUESTS_NUMBER
  end

  def guests_number
    @guests_number ||= @expert_call.guest_ids.count
  end

  def expert
    @expert ||= @expert_call.expert
  end
end
