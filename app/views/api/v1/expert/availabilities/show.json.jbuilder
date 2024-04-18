json.status :success
json.data do
  json.expert_availability do
    json.weekdays do
      json.days @availability.get_weekdays_array
      json.time_start @availability.time_start_weekday
      json.time_end @availability.time_end_weekday
    end
    json.weekend do
      json.days @availability.get_weekend_array
      json.time_start @availability.time_start_weekend
      json.time_end @availability.time_end_weekend
    end
  end
end
