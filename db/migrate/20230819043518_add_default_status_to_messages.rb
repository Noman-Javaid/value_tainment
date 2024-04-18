class AddDefaultStatusToMessages < ActiveRecord::Migration[6.1]
  def change
    change_column :messages, :status, :string, default: 'sent'
  end
end
