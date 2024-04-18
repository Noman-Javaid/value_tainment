# == Schema Information
#
# Table name: users
#
#  id                            :bigint           not null, primary key
#  account_deletion_requested_at :datetime
#  account_verified              :boolean          default(FALSE)
#  active                        :boolean          default(TRUE)
#  admin                         :boolean          default(FALSE)
#  allow_notifications           :boolean          default(FALSE)
#  city                          :string
#  confirmation_sent_at          :datetime
#  confirmation_token            :string
#  confirmed_at                  :datetime
#  consumed_timestep             :integer
#  country                       :string
#  country_code                  :string           default("+1")
#  current_role                  :integer          default("as_individual"), not null
#  date_of_birth                 :date
#  email                         :string           default(""), not null
#  encrypted_otp_secret          :string
#  encrypted_otp_secret_iv       :string
#  encrypted_otp_secret_salt     :string
#  encrypted_password            :string           default(""), not null
#  first_name                    :string
#  gender                        :string
#  is_default                    :boolean          default(FALSE)
#  last_name                     :string
#  otp_backup_codes              :string           is an Array
#  otp_required_for_login        :boolean
#  pending_to_delete             :boolean          default(FALSE)
#  phone                         :string
#  phone_number                  :string
#  phone_number_verified         :boolean          default(FALSE)
#  remember_created_at           :datetime
#  reset_password_sent_at        :datetime
#  reset_password_token          :string
#  status                        :string           default("registered")
#  unconfirmed_email             :string
#  zip_code                      :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  users_name_idx                       (to_tsvector('simple'::regconfig, (((first_name)::text || ' '::text) || (last_name)::text))) USING gin
#
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@user.com" }
    password { '321321321' }
    password_confirmation { password }
    admin { false }
    sequence(:first_name) { |n| "John #{n}" }
    sequence(:last_name) { |n| "Doe #{n}" }
    role { 'individual' }
    active { true }
    confirmed_at { DateTime.now }

    trait :individual do
      role { 'individual' }
    end

    trait :expert do
      role { 'expert' }
    end

    trait :admin do
      admin { true }
      role { nil }
    end

    trait :default do
      is_default { true }
      role { nil }
    end

    trait :with_profile do
      date_of_birth { '19990405' }
      gender { 'male' }
      phone_number { '345392985022' }
      city { 'New York' }
      zip_code { '1653' }
      country { 'US' }
      status { User::STATE_PROFILE_SET }
    end

    trait :with_both_profiles do
      association :expert
      association :individual
    end

    trait :default_with_both_profiles do
      with_both_profiles
      is_default { true }
    end

    after(:build, &:skip_confirmation!)
  end
end
