# == Schema Information
#
# Table name: devices
#
#  id                     :bigint           not null, primary key
#  app_build              :string
#  device_name            :string
#  environment            :string
#  ios_push_notifications :string
#  language               :string
#  os                     :string
#  os_version             :string
#  time_format            :string
#  timezone               :string
#  token                  :string
#  version                :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  user_id                :bigint           not null
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :device do
    association :user, factory: [:user, :with_profile, :individual]
    sequence(:token) { |n| "t9eJjdHkyi0iJ02lsaWd8tZnBh03Y9MSIsaInR3ciI6bnV#{n}" }
    trait :with_android do
      os { 'Android' }
    end
    trait :with_ios do
      os { 'iOS' }
    end
  end
end
