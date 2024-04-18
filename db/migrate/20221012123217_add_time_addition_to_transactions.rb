class AddTimeAdditionToTransactions < ActiveRecord::Migration[6.1]
  def change
    add_reference :transactions, :time_addition, type: :uuid, null: true
    remove_column :transactions, :is_time_addition, :boolean
  end
end
