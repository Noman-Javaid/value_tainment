# == Schema Information
#
# Table name: time_additions
#
#  id             :uuid             not null, primary key
#  duration       :integer
#  payment_status :string
#  rate           :integer
#  status         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  expert_call_id :uuid             not null
#  payment_id     :string
#
# Foreign Keys
#
#  fk_rails_...  (expert_call_id => expert_calls.id)
#
FactoryBot.define do
  factory :time_addition do
    association :expert_call
    rate { 50 }
    duration { 20 * 60 }
  end

  trait :with_payment_data do
    payment_id { 'pi_xxxxxxxxxxxxxx' }
    payment_status { 'succeeded' }
  end
end
