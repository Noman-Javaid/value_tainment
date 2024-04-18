class RemoveUniqueConstraintToQuestions < ActiveRecord::Migration[6.1]
  def change
    remove_index :quick_questions, [:expert_id, :individual_id]
  end
end
