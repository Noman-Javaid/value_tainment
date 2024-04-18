# == Schema Information
#
# Table name: reminders
#
#  id         :bigint           not null, primary key
#  active     :boolean          default(TRUE), not null
#  detail     :string
#  timer      :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :reminder do
    sequence(:timer) { |n| 1.0 + n }
  end
end
