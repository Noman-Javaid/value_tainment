class CreateTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :transactions do |t|
      t.references :individual, null: false, foreign_key: true, type: :uuid
      t.references :expert, null: false, foreign_key: true, type: :uuid
      t.references :expert_interaction, foreign_key: true
      t.integer :amount, null: false
      t.string :charge_type, null: false
      t.string :stripe_transaction_id, null: false

      t.timestamps
    end
  end
end
