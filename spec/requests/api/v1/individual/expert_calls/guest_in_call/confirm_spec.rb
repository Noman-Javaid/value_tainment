require 'rails_helper'

RSpec.describe 'Api::V1::Individual::ConfirmsController', type: :request do
  let(:another_guest_individual) { create(:individual) } # the 1-5 calls needs at least 1 guest
  let(:guest_ids) { [another_guest_individual.id] }
  let(:expert_call_id) { expert_call.id }
  let(:expert_call) { create(:expert_call, call_type: ExpertCall::CALL_TYPE_ONE_TO_FIVE, guest_ids: guest_ids) }
  let(:confirm_expert_call_path) do
    api_v1_individual_expert_call_guest_in_call_confirm_path(
      expert_call_id: expert_call_id
    )
  end
  let(:user) { create(:user, :with_profile) }
  let(:individual) { user.individual }

  context 'with valid authentication and authorization data' do
    describe 'PUT /api/v1/individual/expert_calls/:expert_call_id/guest_in_call/confirm' do
      let(:confirmed) { true }
      let(:params) { { guest_in_call: { confirmed: confirmed } } }

      before do
        put confirm_expert_call_path, headers: auth_headers(user),
                                      params: params.to_json
      end

      # satisfied by parent
      context 'when the expert_call realted to the expert_call_id exists' do
        context 'when the indivudal is a guest in the expert_call ' do
          let(:guest_ids) { [individual.id, another_guest_individual.id] }

          it_behaves_like 'success JSON response'

          it 'matches the expected schema' do
            expect(response).to match_json_schema('v1/expert_call/create')
          end
        end
        # satisfied by parent

        context 'when the indivudal is not a guest in the expert_call ' do
          it_behaves_like 'fail JSON response', :not_found
        end
      end

      context 'when the expert_call realted to the expert_call_id does not exists' do
        let(:expert_call_id) { 'fail' }

        it_behaves_like 'fail JSON response', :not_found
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') do
      let(:execute) { put confirm_expert_call_path, headers: headers }
    end
  end

  context 'with authorization errors' do
    let(:user) { create(:user, :expert) }

    it_behaves_like('being an unauthorized user') do
      let(:execute) { put confirm_expert_call_path, headers: auth_headers(user) }
    end
  end
end
