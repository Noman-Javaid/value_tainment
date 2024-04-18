class Api::V1::Expert::AccountBalancesController < Api::V1::Expert::ExpertsController
  skip_before_action :app_version_supported?
  def show
    # unanswered questions
    @pending_quick_questions = @expert.quick_questions
                                      .pending
                                      .or(@expert.quick_questions.draft_answered)
                                      .has_not_expired
                                      .count
  end
end
