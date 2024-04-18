class ReplaceExpertAccountFields < ActiveRecord::Migration[6.1]
  def change
    change_table :experts, bulk: true do |t|
      t.rename :stripe_connected_account, :stripe_account_id
      t.rename :stripe_requirements_fulfilled, :stripe_account_set
      t.column :stripe_bank_account_id, :string
      t.column :bank_account_last4, :string
      t.index([:stripe_account_id, :stripe_account_set],
              name: :index_experts_stripe_account_id_and_set)
      t.index([:stripe_account_set, :can_receive_stripe_transfers],
              name: :index_experts_stripe_account_set_and_can_get_transfers)
    end
  end
end
