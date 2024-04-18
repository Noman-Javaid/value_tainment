require 'rails_helper'

RSpec.describe 'Api::V1::Individual::ExpertCalls::IndividualSearchController', type: :request do
  describe 'GET /api/v1/individual/expert_calls/individual_search' do
    let(:individual_search_path) { api_v1_individual_expert_calls_individual_search_path }

    context 'with valid authentication and authorization data' do
      let(:user) do
        create(:user, :with_profile, :individual, first_name: 'NOT_FOUND_FNAME0',
                                                  last_name: 'NOT_FOUND_LNAME0', email: 'not_found0@email.com')
      end
      let(:individual) { user.individual }

      let(:search_criteria) { nil }
      let(:individual_search_params) { { search_criteria: search_criteria } }
      let(:params) { { individual_search: individual_search_params } }

      let(:do_request) do
        get individual_search_path, headers: auth_headers(user), params: params
      end

      let!(:individual_outside_search) do # rubocop:todo RSpec/LetSetup
        create(:user, :with_profile, :individual, first_name: 'NOT_FOUND_FNAME1',
                                                  last_name: 'NOT_FOUND_LNAME1', email: 'not_found@email.com')
      end
      # rubocop:todo RSpec/OverwritingSetup
      let!(:individual_outside_search) do # rubocop:todo RSpec/LetSetup
        create(:user, :with_profile, :individual, first_name: 'NOT_FOUND_FNAME1',
                                                  last_name: 'NOT_FOUND_LNAME1', email: 'not_found@email.com')
      end
      # rubocop:enable RSpec/OverwritingSetup

      # satisfied by parent
      context 'when the search_criteria is null' do
        it 'returns the correct result count' do
          do_request
          expect(json['data']['individuals']).to be_empty
        end
      end

      context 'when the search_criteria is not null' do
        let(:search_criteria) { 'matching' }

        context 'when the search_criteria matches some individuals' do
          let!(:users_with_mathcing_name) do
            create_list(:user, 2, :with_profile, :individual,
                        first_name: "#{search_criteria}_fname")
          end
          let!(:users_with_mathcing_last_name) do
            create_list(:user, 2, :with_profile, :individual,
                        last_name: "#{search_criteria}_fname")
          end
          let!(:user_with_mathcing_email) do
            create(:user, :with_profile, :individual,
                   email: "#{search_criteria}@email.com")
          end

          let(:individual_expected_in_search) do
            [*users_with_mathcing_name, *users_with_mathcing_last_name,
             user_with_mathcing_email]
          end
          let(:ids_in_response) do
            json['data']['individuals'].map { |data| data['id'] }
          end

          context 'verifing success response' do # rubocop:todo RSpec/ContextWording
            before { do_request }

            it_behaves_like 'success JSON response'
          end

          it 'returns the correct result count' do
            do_request
            expect(json['results']).to eq(individual_expected_in_search.size)
          end

          it 'returns an Array of experts' do
            do_request
            expect(ids_in_response).to(
              match_array(individual_expected_in_search.map(&:individual).map(&:id))
            )
          end

          it 'matches the expected schema' do
            do_request
            expect(response).to match_json_schema('v1/expert_call/individual_search/show')
          end
        end

        # satisfied by parent
        context 'when the search_criteria does not match some individuals' do
          it 'returns the correct result count' do
            do_request
            expect(json['data']['individuals']).to be_empty
          end
        end
      end
    end

    context 'with authentication errors' do
      it_behaves_like('having an authentication error') do
        let(:execute) { get individual_search_path, headers: headers }
      end
    end

    context 'with authorization errors' do
      let(:user) { create(:user, :expert) }

      it_behaves_like('being an unauthorized user') do
        let(:execute) { get individual_search_path, headers: auth_headers(user) }
      end
    end

    context 'with a disabled account' do
      let(:user) { create(:user, active: false) }

      it_behaves_like('being a disabled user') do
        let(:execute) { get individual_search_path, headers: auth_headers(user) }
      end
    end
  end
end
