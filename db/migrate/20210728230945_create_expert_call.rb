class CreateExpertCall < ActiveRecord::Migration[6.1]
  def change
    create_table :expert_calls, id: :uuid do |t|
      t.references :expert, null: false, foreign_key: true, type: :uuid
      t.references :individual, null: false, foreign_key: true, type: :uuid
      t.references :category, null: false, foreign_key: true
      t.string :call_type, null: false
      t.string :title, null: false
      t.string :description, null: false
      t.datetime :scheduled_time_start, null: false
      t.datetime :scheduled_time_end, null: false
      t.integer :rate, null: false
      t.string :call_status, null: false, default: 'requires_confirmation'
      t.datetime :time_start
      t.datetime :time_end
      t.string :room_id
      t.integer :guests_count, default: 0, null: false
      t.string :complaint
      t.string :payment_id
      t.string :payment_status

      t.timestamps
    end
  end
end
