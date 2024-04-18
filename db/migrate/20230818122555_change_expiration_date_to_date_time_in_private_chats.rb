class ChangeExpirationDateToDateTimeInPrivateChats < ActiveRecord::Migration[6.1]
  def up
    change_column :private_chats, :expiration_date, :datetime, default: -> { "CURRENT_TIMESTAMP + INTERVAL '7 days'" }
  end

  def down
    change_column :private_chats, :expiration_date, :date
  end
end
