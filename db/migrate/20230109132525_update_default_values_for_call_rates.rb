class UpdateDefaultValuesForCallRates < ActiveRecord::Migration[6.1]
  def change
    change_column :experts, :video_call_rate, :integer, default: 15
    change_column :experts, :quick_question_text_rate, :integer, default: 50
    change_column :experts, :quick_question_video_rate, :integer, default: 70
  end
end
