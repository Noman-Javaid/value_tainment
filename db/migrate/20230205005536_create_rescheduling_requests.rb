class CreateReschedulingRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :rescheduling_requests do |t|
      t.references :expert_call, type: :uuid
      t.references :rescheduled_by, polymorphic: true, index: true, type: :uuid
      t.string :rescheduling_reason, limit: 1000, null: true
      t.datetime :new_requested_start_time, null: true
      t.string :status, default: 'pending'
      t.timestamps
    end

  end
end
