class AddIsTimeAdditionAttributeToTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :transactions, :is_time_addition, :boolean, default: false
  end
end
