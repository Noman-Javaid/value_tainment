class ChangeTypeOfQuestionField < ActiveRecord::Migration[6.1]
  def change
    change_column :quick_questions, :question, :string
  end
end
