class CreatePrivateChats < ActiveRecord::Migration[6.1]
  def change
    create_table :private_chats, id: :uuid do |t|
      t.string :name
      t.uuid :created_by, foreign_key: { to_table: :individuals }, type: :uuid
      t.string :users_list, array: true, default: []
      t.string :description
      t.string :short_description
      t.integer :participant_count, null: false, default: 2
      t.string :status, null: false, default: 'pending'
      t.timestamps null: false
    end
  end
end
