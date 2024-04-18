# == Schema Information
#
# Table name: individuals
#
#  id                        :uuid             not null, primary key
#  has_stripe_payment_method :boolean          default(FALSE)
#  ready_for_deletion        :boolean          default(FALSE)
#  username                  :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  stripe_customer_id        :string
#  user_id                   :bigint           not null
#
# Indexes
#
#  index_individuals_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :individual do
    username { Faker::Internet.unique.username }
    association :user, factory: [:user, :with_profile, :individual]

    trait :with_profile do
      sequence(:stripe_customer_id) { |n| "cu_ko310jk32j10j3kadf#{n}" }
      has_stripe_payment_method { true }
    end
  end
end
