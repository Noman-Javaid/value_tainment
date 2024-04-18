# == Schema Information
#
# Table name: transactions
#
#  id                    :bigint           not null, primary key
#  amount                :integer          not null
#  charge_type           :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  expert_id             :uuid             not null
#  expert_interaction_id :bigint
#  individual_id         :uuid             not null
#  payment_id            :uuid
#  stripe_transaction_id :string           not null
#  time_addition_id      :uuid
#
# Indexes
#
#  index_transactions_on_payment_id  (payment_id)
#
# Foreign Keys
#
#  fk_rails_...  (expert_id => experts.id)
#  fk_rails_...  (expert_interaction_id => expert_interactions.id)
#  fk_rails_...  (individual_id => individuals.id)
#  fk_rails_...  (payment_id => payments.id)
#
FactoryBot.define do
  factory :transaction do
    association :individual, :with_profile
    association :expert, :with_profile
    association :expert_interaction, :as_quick_question
    amount { 5000 }
    charge_type { Transaction::CHARGE_TYPE_CONFIRMATION }
    stripe_transaction_id { 'pi_sf0709ud92' }

    trait :with_expert_call do
      association :expert_interaction, :as_expert_call
      amount { 15000 }
    end
  end
end
