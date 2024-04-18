# == Schema Information
#
# Table name: quick_questions
#
#  id                       :uuid             not null, primary key
#  answer                   :text
#  answer_date              :datetime
#  answer_type              :string           default("choose")
#  description              :text             not null
#  payment_status           :string
#  question                 :string           not null
#  rate                     :integer          default(0), not null
#  response_time            :integer
#  status                   :string           default("pending")
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  category_id              :integer
#  expert_id                :uuid             not null
#  individual_id            :uuid             not null
#  payment_id               :string
#  refund_id                :string
#  stripe_payment_method_id :string
#
# Indexes
#
#  index_quick_questions_on_category_id    (category_id)
#  index_quick_questions_on_expert_id      (expert_id)
#  index_quick_questions_on_individual_id  (individual_id)
#
# Foreign Keys
#
#  fk_rails_...  (expert_id => experts.id)
#  fk_rails_...  (individual_id => individuals.id)
#
FactoryBot.define do
  factory :quick_question do
    association :expert, factory: [:expert, :with_profile]
    association :individual, factory: [:individual, :with_profile]
    association :category
    sequence(:question) { |n| "Question number #{n}" }
    description { 'QuickQuestion long description' }
    stripe_payment_method_id { 'pm_sjlkf023jr' }
    payment_id { 'pi_xxxxxxxxxxxxxx' }
    payment_status { 'succeeded' }

    trait :with_answered_data do
      answer { 'Long answer content' }
      answer_date { Time.zone.now }
    end

    trait :answered do
      with_answered_data
      status { 'answered' }
    end

    trait :expired do
      created_at { 4.days.ago(Time.zone.now) }
      status { 'expired' }
    end

    trait :draft_answered do
      answer { 'Long answer content' }
      status { 'draft_answered' }
    end

    trait :filed_complaint do
      with_answered_data
      status { 'filed_complaint' }
    end

    trait :transfered do
      with_answered_data
      status { 'transfered' }
    end

    trait :untransferred do
      with_answered_data
      status { 'untransferred' }
    end

    trait :refunded do
      with_answered_data
      status { 'refunded' }
    end

    trait :failed do
      with_answered_data
      status { 'failed' }
    end

    trait :approved_complaint do
      with_answered_data
      status { 'approved_complaint' }
    end

    trait :without_payment_data do
      payment_id { nil }
      payment_status { nil }
    end

    trait :denied_complaint do
      with_answered_data
      status { 'denied_complaint' }
    end

    # previous payment flow
    trait :with_payment_requires_confirmation do
      payment_status { 'requires_confirmation' }
    end
  end
end
