class AddAnswerTypeToQuickQuestions < ActiveRecord::Migration[6.1]
  def change
    add_column :quick_questions, :answer_type, :string, default: 'choose'
  end
end
