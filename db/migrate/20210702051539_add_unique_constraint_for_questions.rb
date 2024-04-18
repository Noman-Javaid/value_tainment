class AddUniqueConstraintForQuestions < ActiveRecord::Migration[6.1]
  def change
    add_index :quick_questions, [:expert_id, :individual_id], unique: true
  end
end
