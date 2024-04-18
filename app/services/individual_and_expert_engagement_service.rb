class IndividualAndExpertEngagementService
  def initialize(individual_user, expert_user)
    @individual_user = individual_user
    @expert_user = expert_user
  end

  # Result: List of all engagement metrics
  def call
    {
      completed_calls: completed_calls,
      answered_questions: answered_questions
    }
  end

  def completed_calls
    call_engagements.where(call_status: ExpertCall::COMPLETED_STATUS).count
  end

  def answered_questions
    quick_question_engagements.answered_question_list.count
  end

  private

  def call_engagements
    ExpertCall.where(expert: @expert_user, individual: @individual_user)
  end

  def quick_question_engagements
    QuickQuestion.where(expert: @expert_user, individual: @individual_user)
  end
end
