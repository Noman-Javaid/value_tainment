# == Schema Information
#
# Table name: expert_calls
#
#  id                           :uuid             not null, primary key
#  call_status                  :string           default("requires_confirmation"), not null
#  call_time                    :integer          default(0), not null
#  call_type                    :string           not null
#  cancellation_reason          :string(1000)
#  cancelled_at                 :datetime
#  cancelled_by_type            :string
#  description                  :string           not null
#  guests_count                 :integer          default(0), not null
#  payment_status               :string
#  rate                         :integer          not null
#  room_creation_failure_reason :string
#  room_status                  :string           default(NULL)
#  scheduled_call_duration      :integer          default(20), not null
#  scheduled_time_end           :datetime         not null
#  scheduled_time_start         :datetime         not null
#  time_end                     :datetime
#  time_start                   :datetime
#  title                        :string           not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  cancelled_by_id              :uuid
#  category_id                  :integer
#  expert_id                    :uuid             not null
#  individual_id                :uuid             not null
#  payment_id                   :string
#  room_id                      :string
#  stripe_payment_method_id     :string
#
# Indexes
#
#  index_expert_calls_on_cancelled_by   (cancelled_by_type,cancelled_by_id)
#  index_expert_calls_on_category_id    (category_id)
#  index_expert_calls_on_expert_id      (expert_id)
#  index_expert_calls_on_individual_id  (individual_id)
#  index_expert_calls_on_room_status    (room_status)
#
# Foreign Keys
#
#  fk_rails_...  (category_id => categories.id)
#  fk_rails_...  (expert_id => experts.id)
#  fk_rails_...  (individual_id => individuals.id)
#
FactoryBot.define do
  factory :expert_call do
    association :expert, factory: [:expert, :with_profile]
    association :individual, factory: [:individual, :with_profile]
    association :category, factory: [:category]
    sequence(:title) { |n| "Call with expert #{n}" }
    description { 'Call long description' }
    call_type { '1-1' }
    scheduled_time_start { 1.day.from_now(Time.current) }
    stripe_payment_method_id { 'pm_sjlkf023jr' }
    payment_id { 'pi_xxxxxxxxxxxxxx' }
    payment_status { 'succeeded' }

    trait :with_twilio_call_set_up do
      room_id { 'RM_of923r92' }
      time_start { scheduled_time_start }
      time_end { scheduled_call_duration.minutes.from_now(scheduled_time_start) }
    end

    trait :with_1to5 do
      call_type { '1-5' }
      guest_ids { [create(:individual, :with_profile).id] }
    end

    trait :scheduled do
      call_status { 'scheduled' }
    end

    trait :declined do
      call_status { 'declined' }
    end


    trait :expired do
      call_status { 'expired' }
    end

    trait :ongoing do
      room_id { 'RM_of923r92' }
      call_status { 'ongoing' }
    end


    trait :ongoing_with_expert_participant_event do
      ongoing
      participant_events do
        build_list(:participant_event, 1, :with_initial, participant_id: expert.id)
      end
    end

    trait :requires_reschedule_confirmation do
      call_status { 'requires_reschedule_confirmation' }
    end

    trait :finished do
      with_twilio_call_set_up
      call_status { 'finished' }
    end

    trait :transfered do
      with_twilio_call_set_up
      call_status { 'transfered' }
    end

    trait :untransferred do
      with_twilio_call_set_up
      call_status { 'transfered' }
    end

    trait :refunded do
      with_twilio_call_set_up
      call_status { 'refunded' }
    end

    trait :failed do
      with_twilio_call_set_up
      call_status { 'failed' }
    end

    trait :incompleted do
      with_twilio_call_set_up
      call_status { 'incompleted' }
    end

    trait :filed_complaint do
      with_twilio_call_set_up
      call_status { 'filed_complaint' }
    end

    trait :denied_complaint do
      with_twilio_call_set_up
      call_status { 'denied_complaint' }
    end

    trait :approved_complaint do
      with_twilio_call_set_up
      call_status { 'approved_complaint' }
    end

    trait :denied_complaint do
      call_status { 'denied_complaint' }
    end

    trait :without_payment_data do
      payment_id { nil }
      payment_status { nil }
    end

    # previous payment flow
    trait :with_payment_requires_confirmation do
      payment_status { 'requires_confirmation' }
    end

    trait :with_participant_events do
      after(:create) do |expert_call|
        create(:participant_event, :expert_initial_connection, expert_call: expert_call)
        create(:participant_event, :expert_disconnection, expert_call: expert_call)
        create(:participant_event, :individual_connection, expert_call: expert_call)
        create(:participant_event, :individual_disconnection, expert_call: expert_call)
      end
    end
  end
end
