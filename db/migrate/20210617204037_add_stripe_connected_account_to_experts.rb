class AddStripeConnectedAccountToExperts < ActiveRecord::Migration[6.1]
  def change
    add_column :experts, :stripe_connected_account, :string
  end
end
