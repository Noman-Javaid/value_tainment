json.status :success
json.data do
  json.quick_question @quick_question,
                      partial: 'api/v1/individual/quick_questions/quick_question', as: :quick_question
end
