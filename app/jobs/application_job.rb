class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  def save_transaction(interaction, stripe_charge, type)
    Transaction.create({
                         expert: interaction.expert,
                         individual: interaction.individual,
                         expert_interaction: interaction.expert_interaction,
                         amount: stripe_charge.amount,
                         charge_type: type,
                         stripe_transaction_id: stripe_charge.id
                       })
  end

  def finish_calls(ongoing_expert_calls)
    ongoing_expert_calls.each do |call|
      expert_join = call.participant_events&.where(initial: true)
      if expert_join.any?
        call.finish!
      else
        call.set_as_incompleted!
      end
    end
  end
end
