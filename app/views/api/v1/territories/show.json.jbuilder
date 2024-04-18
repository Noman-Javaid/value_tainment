json.status :success
json.data do
  json.territory @territory, partial: 'territory', as: :territory
end
