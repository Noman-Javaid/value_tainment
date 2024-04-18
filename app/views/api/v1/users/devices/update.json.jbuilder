json.status :success
json.data do
  json.device @device, partial: 'api/v1/users/devices/device', as: :device
end
