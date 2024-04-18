class CreateChatRooms < ActiveRecord::Migration[6.1]
  def change
    create_table :chat_rooms do |t|
      t.references :expert_call, foreign_key: true, index: true, null: true, type: :uuid
      t.string :status, default: 'active'
      t.string :sid
      t.string :name, unique: true
      t.jsonb :room_data, default: {}
      t.timestamps
    end
  end
end
