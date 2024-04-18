json.status :success
json.data do
  json.category @category, partial: 'category', as: :category
end
