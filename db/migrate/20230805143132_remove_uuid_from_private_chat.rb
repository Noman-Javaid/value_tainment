class RemoveUuidFromPrivateChat < ActiveRecord::Migration[6.1]
  def change
    remove_column :private_chats, :uuid if column_exists?(:private_chats, :uuid)
  end
end
