# == Schema Information
#
# Table name: category_interactions
#
#  id               :bigint           not null, primary key
#  interaction_type :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  category_id      :bigint           not null
#  interaction_id   :bigint           not null
#
# Foreign Keys
#
#  fk_rails_...  (category_id => categories.id)
#
FactoryBot.define do
  factory :category_interaction do
    association :category
    association :interaction, factory: [:quick_question]
  end
end
