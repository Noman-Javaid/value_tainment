class CreateRefunds < ActiveRecord::Migration[6.1]
  def change
    create_table :refunds do |t|
      t.references :refundable, type: :uuid, polymorphic: true, null: false
      t.string :payment_intent_id_ext
      t.string :refund_id_ext
      t.integer :amount
      t.string :status
      t.jsonb :refund_metadata, null: false, default: '{}'

      t.timestamps
    end
  end
end
