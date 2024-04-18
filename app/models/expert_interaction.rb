# == Schema Information
#
# Table name: expert_interactions
#
#  id               :bigint           not null, primary key
#  feedback         :text
#  interaction_type :string           not null
#  rating           :float
#  reviewed_at      :datetime
#  was_helpful      :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  expert_id        :uuid             not null
#  interaction_id   :uuid             not null
#
# Indexes
#
#  index_expert_interactions_on_expert_id    (expert_id)
#  index_expert_interactions_on_interaction  (interaction_type,interaction_id)
#
# Foreign Keys
#
#  fk_rails_...  (expert_id => experts.id)
#
class ExpertInteraction < ApplicationRecord
  ## Associations
  belongs_to :expert, counter_cache: :interactions_count
  belongs_to :interaction, polymorphic: true
  has_many :complaints, dependent: :destroy
  has_many :transactions, dependent: :destroy

  scope :with_reviews, -> { where.not(feedback: nil).and(where.not(feedback: '')) }
  scope :with_rating, -> { where.not(rating: nil) }
  scope :most_recent, -> { order(updated_at: :desc) }

  delegate :expert_payment, to: :interaction

  def ask_for_feedback?
    case interaction_type
    when 'ExpertCall'
      return false unless was_helpful.nil?

      ExpertCall::COMPLETED_STATUS.include?(interaction.call_status) && Time.zone.now <= 14.days.since(interaction.scheduled_time_end)
    when 'QuickQuestion'

      return false unless was_helpful.nil?
      QuickQuestion::UNANSWERED_STATUS.exclude?(interaction.status) && Time.zone.now <= 14.days.since(interaction.created_at)
    else
      false
    end
  end
end
