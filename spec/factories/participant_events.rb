# == Schema Information
#
# Table name: participant_events
#
#  id             :bigint           not null, primary key
#  duration       :integer
#  event_datetime :datetime         not null
#  event_name     :string           not null
#  expert         :boolean          default(FALSE), not null
#  initial        :boolean          default(FALSE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  expert_call_id :uuid             not null
#  participant_id :string           not null
#
# Foreign Keys
#
#  fk_rails_...  (expert_call_id => expert_calls.id)
#
FactoryBot.define do
  factory :participant_event do
    association :expert_call, factory: [:expert_call]
    participant_id { 'participant_id' }
    event_name { 'participant-connected' }
    event_datetime { Time.current }

    trait :with_initial do
      initial { true }
      expert { true }
    end

    trait :expert_initial_connection do
      participant_id { expert_call.expert_id }
      expert { true }
      initial { true }
      event_datetime { expert_call.scheduled_time_start }
    end

    trait :expert_connection do
      participant_id { expert_call.expert_id }
      expert { true }
      event_datetime { 6.minutes.from_now(expert_call.scheduled_time_start) }
    end

    trait :expert_disconnection do
      participant_id { expert_call.expert_id }
      expert { true }
      event_name { 'participant-disconnected' }
      event_datetime { 5.minutes.from_now(expert_call.scheduled_time_start) }
      duration { 5 * 60 }
    end

    trait :individual_connection do
      participant_id { expert_call.individual_id }
      event_datetime { expert_call.scheduled_time_start }
    end

    trait :individual_disconnection do
      participant_id { expert_call.individual_id }
      event_name { 'participant-disconnected' }
      event_datetime { 10.minutes.from_now(expert_call.scheduled_time_start) }
      duration { 10 * 60 }
    end
  end
end
