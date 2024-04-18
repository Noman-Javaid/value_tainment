# == Schema Information
#
# Table name: setting_variables
#
#  id                             :bigint           not null, primary key
#  question_response_time_in_days :integer          not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#
FactoryBot.define do
  factory :setting_variable do
    question_response_time_in_days { 7 }
  end
end
