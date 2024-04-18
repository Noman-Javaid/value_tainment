json.status :success
json.data do
  json.quick_question @quick_question,
                      partial: 'api/v1/expert/quick_questions/show_quick_question', as: :quick_question
end
