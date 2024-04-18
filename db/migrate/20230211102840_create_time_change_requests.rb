class CreateTimeChangeRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :time_change_requests, id: :uuid do |t|
      t.references :expert_call, type: :uuid
      t.references :requested_by, polymorphic: true, index: true, type: :uuid
      t.string :reason, limit: 1000, null: true
      t.datetime :new_suggested_start_time, null: true
      t.string :status, default: 'pending'
      t.timestamps
    end
  end
end
