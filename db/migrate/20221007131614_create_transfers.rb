class CreateTransfers < ActiveRecord::Migration[6.1]
  def change
    create_table :transfers do |t|
      t.references :transferable, type: :uuid, polymorphic: true, null: false
      t.string :transfer_id_ext
      t.integer :amount
      t.string :destination_account_id_ext
      t.string :balance_transaction_id_ext
      t.string :destination_payment_id_ext
      t.boolean :reversed
      t.jsonb :transfer_metadata, null: false, default: '{}'

      t.timestamps
    end
  end
end
