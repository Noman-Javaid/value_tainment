class AddPayoutPercentageToExperts < ActiveRecord::Migration[6.1]
  def change
    add_column :experts, :payout_percentage, :integer, default: 80
  end
end
