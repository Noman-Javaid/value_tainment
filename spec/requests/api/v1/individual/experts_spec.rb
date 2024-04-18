require 'rails_helper'

RSpec.describe 'Api::V1::Individual::ExpertsController', type: :request do
  let(:experts_search_path) { search_api_v1_individual_experts_path }
  let(:featured_experts_path) { featured_api_v1_individual_experts_path }
  let(:expert_path) { api_v1_individual_expert_path(expert) }

  let(:expert) { create(:expert, :with_profile, status: :verified, user: create(:user, :with_profile)) }

  context 'with valid authentication and authorization data' do
    let(:search_data) { {} }

    let!(:experts) do
      create_list(:expert, 5, :with_profile, :with_categories, status: :verified,
                                                               user: create(:user, :with_profile))
    end

    describe 'GET /api/v1/individual/experts/search' do
      let(:user) { create(:user) }

      before do
        get experts_search_path, headers: auth_headers(user), params: search_data.to_json
      end

      it_behaves_like 'success JSON response'

      it { expect(json['data']).to include('results', 'has_more', 'experts') }

      it 'returns the correct result count' do
        expect(json['data']['results']).to eq(experts.count)
      end

      it 'does not have extra pages' do
        expect(json['data']['has_more']).to eq(false)
      end

      it 'returns an Array of experts' do
        expect(json['data']['experts']).to be_an(Array)
      end
    end

    describe 'GET /api/v1/individual/experts/featured' do
      let(:user) { create(:user) }
      let(:experts_amount) { 3 }
      let!(:group_of_featured_experts) do
        create_list(:expert, experts_amount, :with_profile, :with_categories, featured: true)
      end

      before do
        get featured_experts_path, headers: auth_headers(user)
      end

      it_behaves_like 'success JSON response'

      it 'matches the expected schema' do
        expect(response).to match_json_schema('v1/featured_experts/show')
      end

      context 'when an expert have more than 1 category' do
        let(:another_category) { create(:category) }
        let(:group_of_featured_experts_ids) { group_of_featured_experts.map(&:id) }
        let(:response_ids) do
          json['data']['featured_experts'].map { |expert| expert['id'] }
        end

        before do
          featured_expert = group_of_featured_experts.first
          featured_expert.categories << another_category
          featured_expert.save
        end

        it 'does not return duplicated experts' do
          expect(response_ids).to contain_exactly(*group_of_featured_experts_ids)
        end
      end
    end

    # SHOW
    describe 'GET /api/v1/individual/experts/:expert_id' do
      let(:user) { create(:user) }

      before do
        get expert_path, headers: auth_headers(user)
      end

      context 'with a verified Expert' do
        it_behaves_like 'success JSON response'

        it { expect(json['data']).to include('expert') }

        it 'returns an expert object with correct structure and data' do
          expert.reload
          expect(json['data']['expert']).to include(
            {
              'email' => expert.user.email,
              'first_name' => expert.user.first_name,
              'last_name' => expert.user.last_name,
              'date_of_birth' => expert.user.date_of_birth.to_s,
              'phone_number' => expert.user.phone_number,
              'city' => expert.user.city,
              'zip_code' => expert.user.zip_code,
              'url_picture' => expert.user.url_picture,
              'active' => expert.user.active,
              'gender' => expert.user.gender,
              'country' => expert.user.country,
              'biography' => expert.biography,
              'website_url' => expert.website_url,
              'linkedin_url' => expert.linkedin_url,
              'quick_question_rate' => expert.quick_question_rate,
              'one_to_one_video_call_rate' => expert.one_to_one_video_call_rate,
              'one_to_five_video_call_rate' => expert.one_to_five_video_call_rate,
              'extra_user_rate' => expert.extra_user_rate,
              'age' => expert.age,
              'status' => expert.status,
              'consultation_count' => expert.interactions_count
            }
          )
        end
      end

      context 'when the Expert is not yet verified' do
        let(:expert) { create(:expert, :with_profile, status: :pending, user: create(:user, :with_profile)) }

        it_behaves_like 'success JSON response'
      end

      context 'when the Expert does not exist' do
        let(:expert) { 'fake-id' }

        it_behaves_like 'fail JSON response', :not_found
      end
    end
  end

  context 'with authentication errors' do
    it_behaves_like('having an authentication error') { let(:execute) { get experts_search_path, headers: headers } }
    it_behaves_like('having an authentication error') { let(:execute) { get expert_path, headers: headers } }
  end

  context 'with authorization errors' do
    let(:user) { create(:user, :expert) }

    it_behaves_like('being an unauthorized user') { let(:execute) { get experts_search_path, headers: auth_headers(user) } }
    it_behaves_like('being an unauthorized user') { let(:execute) { get expert_path, headers: auth_headers(user) } }
  end

  context 'with a disabled account' do
    let(:user) { create(:user, active: false) }

    it_behaves_like('being a disabled user') { let(:execute) { get experts_search_path, headers: auth_headers(user) } }
    it_behaves_like('being a disabled user') { let(:execute) { get expert_path, headers: auth_headers(user) } }
  end
end
