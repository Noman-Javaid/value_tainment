class AddStatusColumnToQuickQuestions < ActiveRecord::Migration[6.1]
  def change
    add_column :quick_questions, :status, :string, default: 'pending'
  end
end
