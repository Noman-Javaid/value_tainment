class AddAnswerDateFieldToQuickQuestion < ActiveRecord::Migration[6.1]
  def change
    add_column :quick_questions, :answer_date, :datetime
  end
end
