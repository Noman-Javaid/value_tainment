# == Schema Information
#
# Table name: setting_variables
#
#  id                             :bigint           not null, primary key
#  question_response_time_in_days :integer          not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#
class SettingVariable < ApplicationRecord
  # rubocop:todo Rails/EnvironmentVariableAccess
  GRACE_PERIOD_IN_MINUTES = (ENV['GRACE_PERIOD_IN_MINUTES'] || 1440).to_i.minutes # 1 day
  # rubocop:enable Rails/EnvironmentVariableAccess
  ## Validations
  validates :question_response_time_in_days,
            presence: true,
            numericality: { greater_than_or_equal_to: 1 }

  ## Methods and helpers
  def response_time_to_hours
    question_response_time_in_days * 24
  end

  def response_time_to_minutes
    response_time_to_hours * 60
  end
end
