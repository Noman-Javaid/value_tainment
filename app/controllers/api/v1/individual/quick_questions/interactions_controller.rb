class Api::V1::Individual::QuickQuestions::InteractionsController < Api::V1::Individual::QuickQuestionsController
  before_action :set_quick_question
  before_action :set_expert_interaction

  def update
    update_interaction = Individual::UpdateInteraction.call(@expert_interaction, feedback_params, @individual)

    if update_interaction.success?
      success = true
      message = I18n.t('api.interaction.update_interaction.success.updated')
    else
      success = false
      message = update_interaction.errors[:error_message].join(',')
    end

    render json: { success: success, message: message }
  end

  private

  def feedback_params
    params.require(:quick_question).permit(:was_helpful, :rating, :feedback)
  end

  def set_quick_question
    @quick_question = @individual.quick_questions.find(params[:quick_question_id])
  end

  def set_expert_interaction
    @expert_interaction = @quick_question.expert_interaction
  end
end
