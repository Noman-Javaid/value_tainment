json.extract! expert.user,
              :email,
              :first_name,
              :last_name,
              :date_of_birth,
              :phone_number,
              :phone,
              :country_code,
              :city,
              :zip_code,
              :url_picture,
              :active,
              :gender,
              :country,
              :flag_url
json.extract! expert,
              :id,
              :biography,
              :website_url,
              :linkedin_url,
              :twitter_url,
              :instagram_url,
              :quick_question_rate,
              :one_to_one_video_call_rate,
              :one_to_five_video_call_rate,
              :quick_question_text_rate,
              :quick_question_video_rate,
              :video_call_rate,
              :extra_user_rate,
              :rating,
              :reviews_count,
              :status,
              :slug,
              :age
json.set! :consultation_count, expert.interactions_count
json.categories expert.categories, partial: 'api/v1/individual/categories/category', as: :category
json.total_reviews expert.expert_interactions.with_reviews.count
json.total_ratings expert.expert_interactions.with_rating.count
json.ios_app_download_url I18n.t('app_urls.app_store_url')
json.android_app_download_url I18n.t('app_urls.play_store_url')