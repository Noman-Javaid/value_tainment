class ChangeTextLengthInMessages < ActiveRecord::Migration[6.1]
  def change
    change_column :messages, :text, :text, limit: 1000
  end
end
