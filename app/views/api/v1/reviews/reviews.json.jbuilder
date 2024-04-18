json.status :success
json.next_page @reviews.next_page
json.last_page @reviews.last_page?
json.rating @expert.rating
json.reviews_count @expert.reviews_count
json.total_reviews @reviews.total_count
json.total_ratings @expert.expert_interactions.with_rating.count
json.data do
  json.reviews @reviews, partial: 'api/v1/reviews/review', as: :expert_interaction
end


