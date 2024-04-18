class AddCallTimeColumnToExpertCall < ActiveRecord::Migration[6.1]
  def change
    remove_column :expert_calls, :complaint, :string # rubocop:todo Rails/BulkChangeTable
    add_column :expert_calls, :call_time, :integer, null: false, default: 0
  end
end
