class AddHasStripePaymentMethodToIndividuals < ActiveRecord::Migration[6.1]
  def change
    add_column :individuals, :has_stripe_payment_method, :boolean, default: false
  end
end
