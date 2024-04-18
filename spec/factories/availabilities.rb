# == Schema Information
#
# Table name: availabilities
#
#  id                 :bigint           not null, primary key
#  friday             :boolean          default(FALSE), not null
#  monday             :boolean          default(FALSE), not null
#  saturday           :boolean          default(FALSE), not null
#  sunday             :boolean          default(FALSE), not null
#  thursday           :boolean          default(FALSE), not null
#  time_end_weekday   :string
#  time_end_weekend   :string
#  time_start_weekday :string
#  time_start_weekend :string
#  tuesday            :boolean          default(FALSE), not null
#  wednesday          :boolean          default(FALSE), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  expert_id          :uuid             not null
#
# Foreign Keys
#
#  fk_rails_...  (expert_id => experts.id)
#
FactoryBot.define do
  factory :availability do
    association :expert, factory: [:expert, :with_profile]
    trait :with_full_time do
      monday { true }
      tuesday { true }
      wednesday { true }
      thursday { true }
      friday { true }
      saturday { true }
      sunday { true }
      time_start_weekday { '09:00:00+00:00' }
      time_end_weekday { '16:00:00+00:00' }
      time_start_weekend { '09:00:00+00:00' }
      time_end_weekend { '16:00:00+00:00' }
    end
  end
end
