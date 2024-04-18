class Expert::UpdateEarningsWorker
  include Sidekiq::Worker

  def perform(expert_id = nil)
    # get all the interactions for the expert
    experts = if expert_id.present?
                Expert.where(id: expert_id)
              else
                Expert.all
              end

    experts.each do |expert|
      # loop calls
      total_earnings = 0
      pending_earnings = 0

      expert_calls = expert.expert_calls
      if expert_calls.present?
        expert_calls.each do |expert_call|
          total_earnings += expert_call.expert_payment if expert_call.transfered?
          pending_earnings += expert_call.expert_payment if ExpertCall::PENDING_EARNING_STATUS.include?(expert_call.call_status)
        end
      end

      # loop questions
      expert_questions = expert.quick_questions
      if expert_questions.present?
        expert_questions.each do |question|
          total_earnings += question.expert_payment if question.transfered?
          pending_earnings += question.expert_payment if QuickQuestion::PENDING_EARNING_STATUS.include?(question.status)
        end
      end

      # loop time additions
      expert_time_additions = expert.time_additions
      if expert_time_additions.present?
        expert_time_additions.each do |time_addition|
          total_earnings += time_addition.expert_payment if time_addition.transferred?
          pending_earnings += time_addition.expert_payment if time_addition.pending? || time_addition.confirmed? || time_addition.untransferred? || time_addition.unrefunded?
        end
      end

      expert.update_columns(total_earnings: total_earnings, pending_events: pending_earnings)
    end

  end
end
