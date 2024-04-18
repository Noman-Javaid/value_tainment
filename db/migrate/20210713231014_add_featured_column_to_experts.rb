class AddFeaturedColumnToExperts < ActiveRecord::Migration[6.1]
  def change
    add_column :experts, :featured, :boolean, default: false
  end
end
