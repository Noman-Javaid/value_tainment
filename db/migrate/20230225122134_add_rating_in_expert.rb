class AddRatingInExpert < ActiveRecord::Migration[6.1]
  def change
    add_column :experts, :rating, :float, null: true
  end
end
