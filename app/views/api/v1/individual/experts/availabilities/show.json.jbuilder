json.status :success
json.data do
  json.expert_availability do
    json.date_initial @expert_availability[:date_initial]
    json.date_end @expert_availability[:date_end]
    json.days @expert_availability[:days]
  end
end
