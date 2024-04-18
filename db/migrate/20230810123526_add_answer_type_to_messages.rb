class AddAnswerTypeToMessages < ActiveRecord::Migration[6.1]
  def change
    add_column :messages, :answer_type, :string, default: 'text'
  end
end
