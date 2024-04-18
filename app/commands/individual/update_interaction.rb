# frozen_string_literal: true

class Individual::UpdateInteraction
  prepend SimpleCommand

  attr_accessor :expert_interaction, :interaction, :feedback_params, :individual

  def initialize(expert_interaction, feedback_params, individual)
    @expert_interaction = expert_interaction
    @feedback_params = feedback_params
    @interaction = @expert_interaction.interaction
    @individual = individual
  end

  def call
    (errors.add :error_message, I18n.t('api.interaction.update_interaction.errors.invalid_access')).then { return } if interaction.individual != individual

    (errors.add :error_message, I18n.t('api.interaction.update_interaction.errors.invalid_rating')).then { return } if feedback_params[:rating].present? && !valid_rating?

    (errors.add :error_message, I18n.t('api.interaction.update_interaction.errors.invalid_call_status')).then { return } if @expert_interaction.interaction_type == 'ExpertCall' && !call_completed?

    (errors.add :error_message, I18n.t('api.interaction.update_interaction.errors.already_submitted_or_time_passed')).then { return } if @expert_interaction.interaction_type == 'ExpertCall' && Time.zone.now > 14.days.since(@interaction.scheduled_time_end)
    (errors.add :error_message, I18n.t('api.interaction.update_interaction.errors.already_submitted_or_time_passed')).then { return } if @expert_interaction.interaction_type == 'QuickQuestion' && Time.zone.now > 14.days.since(@interaction.created_at)

    # update interaction with feedback
    feedback_params[:reviewed_at] = Time.zone.now
    expert_interaction.update(feedback_params)
    # update rating
    Expert::UpdateRatingJob.perform_later(interaction.expert.id)
  end

  private

  def valid_rating?
    feedback_params[:rating].to_i >= 1 && feedback_params[:rating].to_i <= 5
  end

  def call_completed?
    ExpertCall::COMPLETED_STATUS.include?(interaction.call_status)
  end

end
