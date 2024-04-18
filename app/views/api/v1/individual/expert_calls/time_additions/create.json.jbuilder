json.status :success
json.data do
  json.time_addition @time_addition, partial: 'api/v1/individual/expert_calls/time_additions/time_addition', as: :time_addition
end
