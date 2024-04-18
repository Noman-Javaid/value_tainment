json.status :success
json.data do
  json.complaint @complaint, partial: 'api/v1/individual/complaints/complaint', as: :complaint
end
