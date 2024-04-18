# == Schema Information
#
# Table name: territories
#
#  id          :bigint           not null, primary key
#  active      :boolean          default(TRUE), not null
#  alpha2_code :string           not null
#  name        :string           not null
#  phone_code  :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :territory do
    name { 'United States' }
    alpha2_code { 'US' }
    phone_code { '1' }
    active { true }

    trait :with_united_kingdom do
      name { 'United Kingdom' }
      alpha2_code { 'GB' }
      phone_code { '44' }
      active { true }
    end

    trait :with_germany do
      name { 'Germany' }
      alpha2_code { 'DE' }
      phone_code { '49' }
      active { true }
    end

    trait :with_spain do
      name { 'Spain' }
      alpha2_code { 'ES' }
      phone_code { '34' }
      active { true }
    end

    trait :with_france do
      name { 'France' }
      alpha2_code { 'FR' }
      phone_code { '33' }
      active { true }
    end

    trait :inactive do
      name { 'Hong Kong SAR China' }
      alpha2_code { 'HK' }
      phone_code { '852' }
      inactive { false }
    end
  end
end
