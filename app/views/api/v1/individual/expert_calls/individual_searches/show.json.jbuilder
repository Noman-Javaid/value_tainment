json.status :success
json.results @users.size
json.has_more !@users.last_page?
json.data do
  json.individuals @users.map(&:individual),
                   partial: 'api/v1/individual/expert_calls/individual', as: :individual
end
