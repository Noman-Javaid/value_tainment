json.status :success
json.data do
  json.top_experts @top_experts,
                        partial: 'api/v1/individual/experts/featured_expert',
                        as: :featured_expert
end
