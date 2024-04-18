class AddCanceledByInExpertCall < ActiveRecord::Migration[6.1]
  def change
    add_reference :expert_calls, :cancelled_by, polymorphic: true, index: true, type: :uuid
    add_column :expert_calls, :cancellation_reason, :string, limit: 1000, null: true
    add_column :expert_calls, :cancelled_at, :datetime, null: true
  end
end
