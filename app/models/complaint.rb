# == Schema Information
#
# Table name: complaints
#
#  id                    :bigint           not null, primary key
#  content               :text
#  status                :string           default("requires_verification"), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  expert_id             :uuid             not null
#  expert_interaction_id :bigint
#  individual_id         :uuid             not null
#
# Foreign Keys
#
#  fk_rails_...  (expert_id => experts.id)
#  fk_rails_...  (expert_interaction_id => expert_interactions.id)
#  fk_rails_...  (individual_id => individuals.id)
#
class Complaint < ApplicationRecord
  ## Inheritance
  include Complaints::StateMachine

  ## Associations
  belongs_to :expert
  belongs_to :individual
  belongs_to :expert_interaction, optional: true

  ## Validations
  validates :content, presence: true, length: { maximum: 1000 }

  ## Callbacks
  after_create :mark_interaction_as_complained
  after_update :resolve_interaction_complaint

  delegate :interaction, to: :expert_interaction, allow_nil: true

  ## Methods and helpers
  private

  def mark_interaction_as_complained
    return unless interaction

    expert_interaction.interaction.set_as_filed_complaint!
  end

  # rubocop:disable Style/GuardClause
  def resolve_interaction_complaint
    return unless interaction

    if expert_interaction.interaction.filed_complaint?
      return expert_interaction.interaction.set_as_approved_complaint! if approved?

      expert_interaction.interaction.set_as_denied_complaint! if denied?
    end
  end
  # rubocop:enable Style/GuardClause
end
