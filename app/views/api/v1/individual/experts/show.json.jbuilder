json.status :success
json.data do
  json.expert @expert, partial: 'api/v1/individual/experts/expert', as: :expert
  if @private_chat.present?
    json.private_chat_id @private_chat.id
  end
end

