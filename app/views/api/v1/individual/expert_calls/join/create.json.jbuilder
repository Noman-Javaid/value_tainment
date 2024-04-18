json.status :success
json.data do
  json.expert_call do
    json.room_name @expert_call.room_id
    json.owner_id @expert_call.individual.id
    json.expert_identity @expert_call.expert.id
    json.token_jwt @token
    json.expert @expert_call.expert == current_user.expert
    json.owner @expert_call.individual == current_user.individual
    json.time_left @time_left
  end
end
