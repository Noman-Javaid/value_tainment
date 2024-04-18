class AddAccountDeletionAttributes < ActiveRecord::Migration[6.1]
  def change
    change_table :users, bulk: true do |t|
      t.boolean :pending_to_delete, default: false
      t.boolean :is_default, default: false
      t.datetime :account_deletion_requested_at
    end

    add_column :experts, :ready_for_deletion, :boolean, default: false
    add_column :individuals, :ready_for_deletion, :boolean, default: false
  end
end
