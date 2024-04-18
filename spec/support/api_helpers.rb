module ApiHelpers
  def json
    JSON.parse(response.body)
  end

  def headers
    { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
  end

  def auth_headers(user)
    Devise::JWT::TestHelpers.auth_headers(headers, user)
  end
end
