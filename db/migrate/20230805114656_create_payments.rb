class CreatePayments < ActiveRecord::Migration[6.1]
  def change
    create_table :payments, id: :uuid do |t|
      t.decimal :amount
      t.string :currency
      t.string :status
      t.references :payable, polymorphic: true, null: false, type: :uuid
      t.string  :payment_id
      t.string :payment_method_id
      t.string :payment_provider, default: 'stripe'
      t.timestamps
    end
  end
end
