class AddExpertAndIndividualToPrivateChats < ActiveRecord::Migration[6.1]
  def change
    add_reference :private_chats, :expert, null: false, foreign_key: true, type: :uuid
    add_reference :private_chats, :individual, null: false, foreign_key: true, type: :uuid
  end
end
