class UpdateReviewsToZero < ActiveRecord::Migration[6.1]
  def change
    Expert.all.each do |expert|
      expert.update_attribute(:reviews_count, 0) if expert.reviews_count.blank?
    end
  end
end
