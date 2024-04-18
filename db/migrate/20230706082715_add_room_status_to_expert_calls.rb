class AddRoomStatusToExpertCalls < ActiveRecord::Migration[6.1]
  def change
    add_column :expert_calls, :room_status, :string
    add_index :expert_calls, :room_status
    add_column :expert_calls, :room_creation_failure_reason, :string
  end
end
