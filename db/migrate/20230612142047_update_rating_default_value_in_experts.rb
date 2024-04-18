class UpdateRatingDefaultValueInExperts < ActiveRecord::Migration[6.1]
  def change
    change_column_default :experts, :rating, 0
  end
end
