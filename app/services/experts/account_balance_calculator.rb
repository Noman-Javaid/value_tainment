class Experts::AccountBalanceCalculator
  def initialize(event, interaction)
    @event = event
    @interaction = interaction
  end

  def call
    send(@event) if private_methods.include?(@event)
  end

  private

  def add_rate_to_expert_pending_events
    add_to_pending_events
  end

  def subtract_rate_to_expert_pending_events
    subtract_to_pending_events
  end

  def add_to_pending_events
    expert.update!(pending_events: expert.pending_events + expert_payment)
  end

  def subtract_to_pending_events
    expert.update!(pending_events: expert.pending_events - expert_payment)
  end

  def subtract_to_total_earnings
    expert.update!(total_earnings: expert.total_earnings - expert_payment)
  end

  def expert
    @expert ||= @interaction.expert
  end

  def expert_payment
    @expert_payment ||= @interaction.expert_payment.to_i
  end

  def time_addition_expert
    @time_addition_expert ||= @interaction.expert_call.expert
  end

  def add_time_addition_rate_to_expert_pending_events
    time_addition_expert.update!(
      pending_events: time_addition_expert.pending_events + expert_payment
    )
  end

  def subtract_time_addition_rate_to_expert_pending_events
    time_addition_expert.update!(
      pending_events: time_addition_expert.pending_events - expert_payment
    )
  end
end
