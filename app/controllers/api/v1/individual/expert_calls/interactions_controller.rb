class Api::V1::Individual::ExpertCalls::InteractionsController < Api::V1::Individual::IndividualsController
  before_action :set_expert_call
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
    params.require(:expert_call).permit(:was_helpful, :rating, :feedback)
  end

  def set_expert_call
    @expert_call = @individual.expert_calls.find(params[:expert_call_id])
  end

  def set_expert_interaction
    @expert_interaction = @expert_call.expert_interaction
  end
end
