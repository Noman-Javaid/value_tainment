class UpdateRatingToZero < ActiveRecord::Migration[6.1]
  def change
    Expert.all.each do |expert|
      expert.update_attribute(:rating, 0) if expert.rating.blank?
    end
  end
end
