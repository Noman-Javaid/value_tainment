class ChangeColumnNullRestrictionInQuickQuestions < ActiveRecord::Migration[6.1]
  def up
    change_column :quick_questions, :payment_id, :string, null: true # rubocop:todo Rails/BulkChangeTable
    change_column :quick_questions, :payment_status, :string, null: true
  end

  def down
    change_column :quick_questions, :payment_id, :string, null: false # rubocop:todo Rails/BulkChangeTable
    change_column :quick_questions, :payment_status, :string, null: false
  end
end
