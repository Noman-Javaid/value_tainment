class UpdateSettingVarForQuickQuestionTime < ActiveRecord::Migration[6.1]
  def change
    SettingVariable.update_all(question_response_time_in_days: 5)
  end
end
