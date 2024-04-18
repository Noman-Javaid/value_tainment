class CreateDevices < ActiveRecord::Migration[6.1]
  def change
    create_table :devices do |t|
      t.string :token
      t.string :os
      t.references :user, null: false, foreign_key: true
      t.string :version
      t.string :device_name
      t.string :language
      t.string :timezone
      t.string :time_format
      t.string :os_version
      t.string :app_build
      t.string :environment
      t.string :ios_push_notifications

      t.timestamps
    end
    add_index :devices, [:user_id, :token], unique: true
  end
end
