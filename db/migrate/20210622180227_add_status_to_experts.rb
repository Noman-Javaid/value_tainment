class AddStatusToExperts < ActiveRecord::Migration[6.1]
  def change
    add_column :experts, :status, :integer, default: 0
  end
end
