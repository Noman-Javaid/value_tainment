class AddRateColumnToQuickQuestion < ActiveRecord::Migration[6.1]
  def change
    add_column :quick_questions, :rate, :integer, default: 0, null: false
  end
end
