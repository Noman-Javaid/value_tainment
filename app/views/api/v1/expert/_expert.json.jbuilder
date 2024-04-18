json.extract! expert, :id, :biography, :website_url, :linkedin_url, :quick_question_rate,
              :one_to_one_video_call_rate, :one_to_five_video_call_rate,
              :quick_question_text_rate, :quick_question_video_rate, :video_call_rate,
              :extra_user_rate, :status, :twitter_url, :instagram_url,
              :rating,
              :reviews_count,
              :stripe_account_set,
              :can_receive_stripe_transfers,
              :slug,
              :bank_account_last4,
              :url_picture
json.set! :consultation_count, expert.interactions_count
json.categories(expert.categories) do |category|
  json.partial! partial: 'api/v1/categories/category', category: category
end
json.first_name expert.first_name
json.last_name expert.last_name
json.total_reviews expert.expert_interactions.with_reviews.count
json.total_ratings expert.expert_interactions.with_rating.count
json.first_name expert.first_name
json.last_name expert.last_name