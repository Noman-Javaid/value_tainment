json.status :success
json.data do
  json.two_factor_enabled true
  json.backup_code @backup_code
end
