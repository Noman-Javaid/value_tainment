json.status :success
json.results @events.size
json.has_more !@events.last_page?
json.total @events.total_count
json.current_page @events.current_page
json.data do
  json.events @events, partial: 'api/v1/individual/expert_calls/expert_call', as: :expert_call
end
