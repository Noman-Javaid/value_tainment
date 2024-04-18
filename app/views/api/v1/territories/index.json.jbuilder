json.status :success
json.data do
  json.territories @territories, :id, :name, :alpha2_code, :phone_code, :active, :flag_url
end
