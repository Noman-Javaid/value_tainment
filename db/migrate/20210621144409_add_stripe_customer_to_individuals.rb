class AddStripeCustomerToIndividuals < ActiveRecord::Migration[6.1]
  def change
    add_column :individuals, :stripe_customer, :string
  end
end
