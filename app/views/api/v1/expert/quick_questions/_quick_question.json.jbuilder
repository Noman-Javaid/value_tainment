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
              :created_at,
              :was_helpful,
              :rating,
              :feedback,
              :reviewed_at
case quick_question.status
when 'untransferred'
  json.status 'answered'
when 'unrefunded'
  json.status 'expired'
else
  json.status quick_question.status
end
json.has_attachment quick_question.attachment_url?
json.individual_name quick_question.individual_name
json.individual_picture quick_question.individual_url_picture
json.category_id quick_question.category_id
json.category_name quick_question.category_name
json.ask_for_feedback quick_question.ask_for_feedback?