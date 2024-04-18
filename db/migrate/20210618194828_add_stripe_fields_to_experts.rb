class AddStripeFieldsToExperts < ActiveRecord::Migration[6.1]
  def change
    add_column :experts, :stripe_requirements_fulfilled, :boolean, default: false # rubocop:todo Rails/BulkChangeTable
    add_column :experts, :can_receive_stripe_transfers, :boolean, default: false
  end
end
