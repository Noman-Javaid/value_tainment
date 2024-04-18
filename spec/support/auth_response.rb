RSpec.shared_examples_for 'having an authentication error' do
  context 'when the user is not authenticated' do
    it 'responds with the default error when the user is not authenticated' do
      execute

      expect(json).to include('status', 'message')
      expect(response).to have_http_status(:unauthorized)
      expect(response.content_type).to include('application/json')
      expect(json['status']).to eq('error')
      expect(json['message']).to eq('You need to sign in or sign up before continuing.')
    end
  end
end

RSpec.shared_examples_for 'being an unauthorized user' do
  context 'when the user does not fit the expected role' do
    before { execute }

    it { expect(json).to include('status', 'message') }
    it { expect(response).to have_http_status(:unauthorized) }
    it { expect(response.content_type).to include('application/json') }
    it { expect(json['status']).to eq('error') }
  end
end

RSpec.shared_examples_for 'being a disabled user' do
  context 'when the user account has been deactivated' do
    it 'responds with a default deactivation error' do
      execute

      expect(json).to include('status', 'message')
      expect(response).to have_http_status(:unauthorized)
      expect(response.content_type).to include('application/json')
      expect(json['status']).to eq('error')
      expect(json['message']).to eq('This account has been deactivated')
    end
  end
end
