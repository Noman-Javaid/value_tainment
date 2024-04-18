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
FactoryBot.define do
  factory :complaint do
    association :individual
    association :expert
    status { 'requires_verification' }
    content { 'my complaint' }
    trait :with_question_interaction do
      association :expert_interaction, factory: [:expert_interaction, :as_quick_question]
    end
    trait :with_call_interaction do
      association :expert_interaction, factory: [:expert_interaction, :as_expert_call]
    end
  end
end
