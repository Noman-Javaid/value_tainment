class AddReviewsCountInExpert < ActiveRecord::Migration[6.1]
  def change
    add_column :experts, :reviews_count, :integer
  end
end
