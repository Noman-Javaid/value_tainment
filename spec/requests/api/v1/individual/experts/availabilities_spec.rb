require 'rails_helper'

RSpec.describe 'Api::V1::Individual::Experts::AvailabilitiesController', type: :request do
  let(:expert_availability_path) { api_v1_individual_expert_availability_path(expert_id: expert_id) }
  let(:expert) { create(:expert, :with_profile, status: :verified) }
  let(:user) { create(:user, :with_profile) }
  let(:individual) { user.individual }
  let!(:expert_availability) { create(:availability, :with_full_time, expert: expert) } # rubocop:todo RSpec/LetSetup
  let(:expert_id) { expert.id }

  context 'with valid authentication and authorization data' do
    describe 'GET /api/v1/individual/experts/:expert_id/availability' do
      before do
        stub_const('ExpertCall::DEFAULT_CALL_DURATION', 20)
        get expert_availability_path, headers: auth_headers(user)
      end

      it_behaves_like 'success JSON response'

      it 'matches the expected schema' do
        expect(response).to match_json_schema('v1/availabilities/individual/show')
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') { let(:execute) { get expert_availability_path, headers: headers } }
  end

  context 'with authorization errors' do
    let(:user) { create(:user, :expert) }

    it_behaves_like('being an unauthorized user') { let(:execute) { get expert_availability_path, headers: auth_headers(user) } }
  end

  context 'with a disabled account' do
    let(:user) { create(:user, :individual, active: false) }

    it_behaves_like('being a disabled user') { let(:execute) { get expert_availability_path, headers: auth_headers(user) } }
  end
end
