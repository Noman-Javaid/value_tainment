json.status :success
json.data do
  json.quick_questions @quick_questions, partial: 'api/v1/individual/quick_questions/quick_question', as: :quick_question
end
