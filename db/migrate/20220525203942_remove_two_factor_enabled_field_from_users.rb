class RemoveTwoFactorEnabledFieldFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :two_factor_enabled, :boolean
  end
end
