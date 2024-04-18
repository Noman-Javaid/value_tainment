class CreateTimeAdditions < ActiveRecord::Migration[6.1]
  def change
    create_table :time_additions, id: :uuid do |t|
      t.references :expert_call, null: false, foreign_key: true, type: :uuid
      t.string :status
      t.integer :duration
      t.integer :rate
      t.string :payment_status

      t.timestamps
    end
  end
end
