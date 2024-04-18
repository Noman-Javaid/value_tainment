json.status :success
json.data do
  json.categories @categories, :id, :name, :description
end
