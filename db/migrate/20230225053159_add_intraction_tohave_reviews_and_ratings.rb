class AddIntractionTohaveReviewsAndRatings < ActiveRecord::Migration[6.1]
  def change
    add_column :expert_interactions, :rating, :float
    add_column :expert_interactions, :feedback, :text
  end
end
