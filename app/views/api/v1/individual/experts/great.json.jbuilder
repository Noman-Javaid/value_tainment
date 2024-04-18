json.status :success
json.data do
  json.great_experts @great_experts,
                        partial: 'api/v1/individual/experts/featured_expert',
                        as: :featured_expert
end
