json.status :success
json.data do
  json.quick_question @quick_question, partial: 'api/v1/individual/quick_questions/quick_question', as: :quick_question
  json.expert @expert, partial: 'api/v1/individual/experts/expert', as: :expert
  json.client_secret @client_secret
end
