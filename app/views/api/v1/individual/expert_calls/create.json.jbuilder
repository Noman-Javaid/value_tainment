json.status :success
json.data do
  json.expert_call @expert_call, partial: 'api/v1/individual/expert_calls/expert_call', as: :expert_call
  json.client_secret @client_secret
end
