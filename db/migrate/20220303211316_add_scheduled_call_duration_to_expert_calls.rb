class AddScheduledCallDurationToExpertCalls < ActiveRecord::Migration[6.1]
  def change
    add_column :expert_calls, :scheduled_call_duration, :integer, null: false, default: 20
  end
end
