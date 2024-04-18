class Expert::UpdateRatingJob < ApplicationJob
  queue_as :default

  def perform(expert_id)
    expert = Expert.find(expert_id)
    interactions_with_rating = expert.expert_interactions.where.not(rating: nil)
    average_rating = interactions_with_rating.average(:rating)
    expert.update(rating: average_rating.round(2), reviews_count: expert.expert_interactions.with_reviews.count)
  rescue StandardError => e
    Rails.logger.info(message: 'Error occurred in the updating the rating', expert_id: expert_id, error: e.message)
  end
end
