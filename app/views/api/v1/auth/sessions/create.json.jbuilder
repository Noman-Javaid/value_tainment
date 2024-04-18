json.status :success
json.data do
  json.user do
    json.partial! 'api/v1/users/user', locals: { user: @user, profile: @profile }
  end
end
