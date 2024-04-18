json.extract! featured_expert,
              :id,
              :status,
              :url_picture,
              :rating,
              :reviews_count,
              :slug
json.extract! featured_expert.user,
              :first_name,
              :last_name
json.set! :consultation_count, featured_expert.interactions_count
json.total_reviews featured_expert.total_reviews
json.total_ratings featured_expert.total_ratings