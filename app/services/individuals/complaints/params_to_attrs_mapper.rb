class Individuals::Complaints::ParamsToAttrsMapper
  def initialize(params)
    @params = params
  end

  def call
    complaint_hash = @params.merge({})
    expert_interaction_hash =
      if @params[:quick_question_id]
        complaint_hash.delete(:quick_question_id)
        get_expert_interaction_hash(
          @params[:quick_question_id], true
        )
      elsif @params[:expert_call_id]
        complaint_hash.delete(:expert_call_id)
        get_expert_interaction_hash(@params[:expert_call_id])
      else
        {}
      end
    complaint_hash.merge(expert_interaction_hash)
  end

  private

  def get_expert_interaction_hash(interaction, is_quick_question = false) # rubocop:todo Style/OptionalBooleanParameter
    interaction_id =
      if is_quick_question
        QuickQuestion.find(interaction).expert_interaction&.id
      else
        ExpertCall.find(interaction).expert_interaction&.id
      end
    { expert_interaction_id: interaction_id }
  end
end
