class AddPrivateChatToMessages < ActiveRecord::Migration[6.1]
  def change
    add_reference :messages, :private_chat, null: false, foreign_key: true, type: :uuid
  end
end
