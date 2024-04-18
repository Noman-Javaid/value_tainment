class AddAllowNotificationsColumnToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :allow_notifications, :boolean, default: false
  end
end
