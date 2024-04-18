FactoryBot.define do
  factory :guest_in_call do
    association :expert_call, factory: [:expert_call, :ongoing]
    association :individual, factory: [:individual, :with_profile]
  end
end
