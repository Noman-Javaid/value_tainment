class AddPaymentIdToTransactions < ActiveRecord::Migration[6.1]
  def change
    add_reference :transactions, :payment, foreign_key: true, type: :uuid
  end
end
