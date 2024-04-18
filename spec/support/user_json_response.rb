RSpec.shared_examples_for 'user JSON response' do
  it 'returns a user object' do
    expect(json['data']).to include('user')
  end

  it 'returns a user object with correct structure and data' do
    expect(json['data']['user']).to include(
      {
        'email' => user.email,
        'first_name' => user.first_name,
        'last_name' => user.last_name,
        'role' => user.role,
        'active' => user.active,
        'requires_confirmation' => !user.confirmed?
      }
    )
  end
end
