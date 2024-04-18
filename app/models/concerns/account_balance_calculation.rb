module AccountBalanceCalculation
  extend ActiveSupport::Concern

  def add_rate_to_expert_pending_events
    return unless rate

    Experts::AccountBalanceCalculator.new(:add_rate_to_expert_pending_events, self).call
  end

  def subtract_rate_to_expert_pending_events
    Experts::AccountBalanceCalculator.new(
      :subtract_rate_to_expert_pending_events, self
    ).call
  end

  def add_time_addition_rate_to_expert_pending_events
    Experts::AccountBalanceCalculator.new(
      :add_time_addition_rate_to_expert_pending_events, self
    ).call
  end

  def subtract_time_addition_rate_to_expert_pending_events
    Experts::AccountBalanceCalculator.new(
      :subtract_time_addition_rate_to_expert_pending_events, self
    ).call
  end
end
