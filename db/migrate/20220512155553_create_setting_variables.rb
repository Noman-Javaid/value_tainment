class CreateSettingVariables < ActiveRecord::Migration[6.1]
  def change
    create_table :setting_variables do |t|
      t.integer :question_response_time_in_days, null: false
      t.timestamps
    end
  end
end
