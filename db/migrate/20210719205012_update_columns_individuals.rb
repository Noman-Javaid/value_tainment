class UpdateColumnsIndividuals < ActiveRecord::Migration[6.1]
  def change
    rename_column :individuals, :stripe_customer, :stripe_customer_id
    remove_column :individuals, :username, :string
  end
end
