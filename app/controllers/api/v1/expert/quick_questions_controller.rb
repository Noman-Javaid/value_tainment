class Api::V1::Expert::QuickQuestionsController < Api::V1::Expert::ExpertsController
  def index
    @quick_questions = @expert.quick_questions.includes(
      :category, individual: { user: :picture_attachment }
    )
    if params[:query].present?
      @quick_questions = @quick_questions.ransack(params[:query]).result
    elsif params[:completed] == 'true'
      @quick_questions = @quick_questions.answered_question_list
    end
    # sort with created at
    @quick_questions = @quick_questions.most_recent.page(params[:page]).per(params[:per_page])
  end

  def show
    quick_question
  end

  def update
    quick_question.update!(update_params.merge(
                             answered_as_draft: answered_as_draft,
                             answer_date: answered_as_draft ? nil : Time.current.utc
    ))
  end

  private

  def answered_as_draft
    update_params[:answered_as_draft] || false
  end

  def update_params
    params.require(:quick_question).permit(:answer, :answered_as_draft)
  end

  def quick_question
    @quick_question ||= @expert.quick_questions.find(params[:id])
  end
end
