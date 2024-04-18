json.extract! quick_question,
              :id,
              :expert_id,
              :individual_id,
              :question,
              :description,
              :answer,
              :answer_type,
              :parsed_answer,
              :answer_date,
              :payment_status,
              :time_left,
              :rate,
              :is_answered,
              :was_helpful,
              :rating,
              :feedback,
              :created_at
case quick_question.status
when 'untransferred'
  json.status 'answered'
when 'unrefunded'
  json.status 'expired'
else
  json.status quick_question.status
end
json.has_attachment quick_question.attachment_url?
json.expert_name quick_question.expert_name
json.expert_picture quick_question.expert_url_picture
json.expert_status quick_question.expert_status
json.category_id quick_question.category_id
json.category_name quick_question.category_name
json.ask_for_feedback quick_question.ask_for_feedback?
json.expert_rating quick_question.expert_rating
json.expert_reviews_count quick_question.expert_reviews_count
json.total_ratings quick_question.expert_total_ratings
json.total_reviews quick_question.expert_total_reviews
