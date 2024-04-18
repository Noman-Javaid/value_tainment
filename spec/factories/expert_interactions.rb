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
FactoryBot.define do
  factory :expert_interaction do
    association :expert
    trait :as_quick_question do
      association :interaction, factory: [:quick_question]
      interaction_type { interaction.class.to_s }
    end
    trait :as_expert_call do
      association :interaction, factory: [:expert_call]
      interaction_type { interaction.class.to_s }
    end
  end
end
