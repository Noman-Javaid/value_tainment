class AddExpirationDateToMessages < ActiveRecord::Migration[6.1]
  def change
    add_column :private_chats, :expiration_date, :date, default: -> { "CURRENT_DATE + INTERVAL '7 days'" }
  end
end
