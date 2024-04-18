class AddPaymentIdAttributeToTimeAdditions < ActiveRecord::Migration[6.1]
  def change
    add_column :time_additions, :payment_id, :string
  end
end
