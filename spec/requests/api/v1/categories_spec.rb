require 'rails_helper'

RSpec.describe 'Api::V1::CategoriesController', type: :request do
  let(:category) { create(:category) }
  let(:user) { create(:user, :expert) }
  let(:categories_path) { api_v1_categories_path }

  context 'with valid authentication and authorization data' do
    describe 'GET /categories/:id' do
      before do
        get api_v1_category_path(id: category.id), headers: auth_headers(user)
      end

      context 'with proper response' do
        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/categories/show')
        end
      end
    end

    describe 'GET /categories' do
      before do
        category
        get categories_path, headers: auth_headers(user)
      end

      context 'with proper response' do
        it_behaves_like 'success JSON response'

        it 'matches the expected schema' do
          expect(response).to match_json_schema('v1/categories/index')
        end
      end
    end
  end

end
