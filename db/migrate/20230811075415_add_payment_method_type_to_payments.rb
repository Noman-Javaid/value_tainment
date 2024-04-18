class AddPaymentMethodTypeToPayments < ActiveRecord::Migration[6.1]
  def change
    add_column :payments, :payment_method_types, :string, array: true, default: ['card']
  end
end
