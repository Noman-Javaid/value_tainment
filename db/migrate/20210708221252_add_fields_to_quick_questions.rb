class AddFieldsToQuickQuestions < ActiveRecord::Migration[6.1]
  def change
    # rubocop:todo Rails/NotNullColumn
    add_column :quick_questions, :description, :text, null: false # rubocop:todo Rails/BulkChangeTable
    # rubocop:enable Rails/NotNullColumn
    add_column :quick_questions, :category, :string, null: false # rubocop:todo Rails/NotNullColumn
  end
end
