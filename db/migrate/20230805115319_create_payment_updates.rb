class CreatePaymentUpdates < ActiveRecord::Migration[6.1]
  def change
    create_table :payment_updates, id: :uuid do |t|
      t.references :payment, null: false, foreign_key: true, type: :uuid
      t.json :changes
      t.string :status

      t.timestamps
    end
  end
end
