json.status :success
json.data do
  json.featured_experts @featured_experts,
                        partial: 'api/v1/individual/experts/featured_expert',
                        as: :featured_expert
end
json.results @featured_experts.total_count
json.total_pages @featured_experts.total_pages
json.current_page @featured_experts.current_page
json.next_page @featured_experts.next_page
json.prev_page @featured_experts.prev_page
json.has_more !@featured_experts.last_page?