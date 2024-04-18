class AddTotalEarningsAndPendingEventsColumnsToExpert < ActiveRecord::Migration[6.1]
  def change
    change_table :experts, bulk: true do |t|
      t.integer :total_earnings, default: 0, null: false
      t.integer :pending_events, default: 0, null: false
    end
  end
end
