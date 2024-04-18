class AddTimeToResponseToQuickQuestions < ActiveRecord::Migration[6.1]
  def change
    add_column :quick_questions, :response_time, :integer
  end
end
