# == Schema Information
#
# Table name: account_deletion_follow_ups
#
#  id                      :bigint           not null, primary key
#  notes                   :text
#  required_for_expert     :boolean          default(FALSE)
#  required_for_individual :boolean          default(FALSE)
#  status                  :integer          default("created")
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  stripe_account_id       :string
#  stripe_customer_id      :string
#  user_id                 :bigint
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :account_deletion_follow_up do
    association :user

    trait :requires_revision do
      status { 'requires_revision' }
    end

    trait :in_revision do
      status { 'in_revision' }
    end

    trait :resolved do
      status { 'resolved' }
    end

    trait :with_customer_id do
      customer_id { 'cus_123' }
    end

    trait :with_stripe_account_id do
      stripe_account_id { 'ac_123' }
    end

    trait :required_for_individual do
      required_for_individual { true }
    end

    trait :required_for_expert do
      required_for_expert { true }
    end
  end
end
