class Api::V1::Individual::QuickQuestions::AttachmentsController <
      Api::V1::Individual::QuickQuestionsController
  before_action :set_quick_question, only: %i[show]
  before_action :set_attachment, only: %i[show]

  def show
    @attachment.get_attachment_url
    render 'api/v1/expert/quick_questions/attachment/show'
  end

  private

  def set_quick_question
    @quick_question = @individual.quick_questions.find(params[:quick_question_id])
  end

  def set_attachment
    @attachment = @quick_question.attachment
    raise ActiveRecord::RecordNotFound unless @attachment
  end
end
