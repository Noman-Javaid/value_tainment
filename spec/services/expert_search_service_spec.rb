require 'rails_helper'

describe ExpertSearchService do
  let!(:expert_search_service) { described_class.new(params) }
  let(:category1) { create(:category) }
  let(:category2) { create(:category) }
  let(:category3) { create(:category) }
  let!(:expert1) do
    create(:expert, :with_profile,
           status: :verified,
           user: create(:user, :with_profile, first_name: 'First 1',
                                              last_name: 'Last 1'),
           categories: [category1],
           quick_question_rate: 50,
           one_to_one_video_call_rate: 50,
           one_to_five_video_call_rate: 50,
           extra_user_rate: 50,
           slug: 'slug')
  end
  let!(:expert2) do
    create(:expert, :with_profile,
           status: :verified,
           user: create(:user, :with_profile, first_name: 'First 2',
                                              last_name: 'Last 2'),
           categories: [category1, category2],
           quick_question_rate: 70,
           one_to_one_video_call_rate: 70,
           one_to_five_video_call_rate: 70,
           extra_user_rate: 70, slug: 'slug')
  end
  let(:all_experts) { [expert1, expert2] }

  describe '#execute' do
    let(:valid_rate_fields) do
      %w[
        quick_question_rate
        one_to_one_video_call_rate
        one_to_five_video_call_rate
        extra_user_rate
      ]
    end

    context 'without any param' do
      let(:params) { {} }

      it 'returns all the experts' do
        expect(expert_search_service.execute).to contain_exactly(*all_experts)
      end
    end

    context 'when filtering by name' do
      context 'when the filter value is "First 1"' do
        let(:params) { { name: 'First 1' } }

        it 'returns only the expert 1' do
          expect(expert_search_service.execute).to match_array([expert1])
        end
      end

      context 'when the filter value is "First"' do
        let(:params) { { name: 'First' } }

        it 'returns the expert 1 and expert 2' do
          expect(expert_search_service.execute).to match_array([expert1, expert2])
        end
      end

      context 'when the filter value is "An invalid search string"' do
        let(:params) { { name: 'An invalid search string' } }

        it 'returns an empty list' do
          expect(expert_search_service.execute).to be_empty
        end
      end
    end

    %w[quick_question_rate
       one_to_one_video_call_rate
       one_to_five_video_call_rate
       extra_user_rate].each do |rate_field|
      context 'when filtering by minimum rate' do
        context "when the field is #{rate_field}" do
          context 'when the minimum rate is 55' do
            let(:params) { { rates: { field: rate_field, minimum: 55 } } }

            it 'returns only the expert 2' do
              expect(expert_search_service.execute).to contain_exactly(expert2)
            end
          end

          context 'when the minimum rate is 70' do
            let(:params) { { rates: { field: rate_field, minimum: 70 } } }

            it 'returns only the expert 2' do
              expect(expert_search_service.execute).to contain_exactly(expert2)
            end
          end

          context 'when the minimum rate is 50' do
            let(:params) { { rates: { field: rate_field, minimum: 50 } } }

            it 'returns the expert 1 and expert 2' do
              expect(expert_search_service.execute).to contain_exactly(expert1, expert2)
            end
          end

          context 'when the minimum rate is 0' do
            let(:params) { { rates: { field: rate_field, minimum: 0 } } }

            it 'returns the expert 1 and expert 2' do
              expect(expert_search_service.execute).to contain_exactly(expert1, expert2)
            end
          end

          context 'when the minimum rate is not defined' do
            let(:params) { { rates: { field: rate_field } } }

            it 'returns the expert 1 and expert 2' do
              expect(expert_search_service.execute).to contain_exactly(expert1, expert2)
            end
          end

          context 'when the minimum rate is 80' do
            let(:params) { { rates: { field: rate_field, minimum: 80 } } }

            it 'returns an empty list' do
              expect(expert_search_service.execute).to be_empty
            end
          end
        end
      end

      context 'when filtering by maximum rate' do
        context "when the field is #{rate_field}" do
          context 'when the maximum rate is 55' do
            let(:params) { { rates: { field: rate_field, maximum: 55 } } }

            it 'returns only the expert 1' do
              expect(expert_search_service.execute).to contain_exactly(expert1)
            end
          end

          context 'when the maximum rate is 70' do
            let(:params) { { rates: { field: rate_field, maximum: 70 } } }

            it 'returns the expert 1 and expert 2' do
              expect(expert_search_service.execute).to contain_exactly(expert1, expert2)
            end
          end

          context 'when the maximum rate is 50' do
            let(:params) { { rates: { field: rate_field, maximum: 50 } } }

            it 'returns only the expert 1' do
              expect(expert_search_service.execute).to contain_exactly(expert1)
            end
          end

          context 'when the maximum rate is 0' do
            let(:params) { { rates: { field: rate_field, maximum: 0 } } }

            it 'returns an empty list' do
              expect(expert_search_service.execute).to be_empty
            end
          end

          context 'when the maximum rate is not defined' do
            let(:params) { { rates: { field: rate_field } } }

            it 'returns the expert 1 and expert 2' do
              expect(expert_search_service.execute).to contain_exactly(expert1, expert2)
            end
          end

          context 'when the maximum rate is 80' do
            let(:params) { { rates: { field: rate_field, maximum: 80 } } }

            it 'returns the expert 1 and expert 2' do
              expect(expert_search_service.execute).to contain_exactly(expert1, expert2)
            end
          end
        end
      end
    end

    context 'when filtering by categories' do
      context 'with category 1 and category 2' do
        let(:params) { { categories: [category1.id, category2.id] } }

        it 'returns the expert 1 and expert 2' do
          expect(expert_search_service.execute).to contain_exactly(expert1, expert2)
        end
      end

      context 'with only category 1' do
        let(:params) { { categories: [category1.id] } }

        it 'returns the expert 1 and expert 2' do
          expect(expert_search_service.execute).to contain_exactly(expert1, expert2)
        end
      end

      context 'with only category 2' do
        let(:params) { { categories: [category2.id] } }

        it 'returns only the expert 2' do
          expect(expert_search_service.execute).to contain_exactly(expert2)
        end
      end

      context 'with an empty array' do
        let(:params) { { categories: [] } }

        it 'returns all the experts' do
          expect(expert_search_service.execute).to contain_exactly(*all_experts)
        end
      end

      context 'with a category not related to any expert' do
        let(:params) { { categories: [category3.id] } }

        it 'returns an empty list' do
          expect(expert_search_service.execute).to be_empty
        end
      end

      context 'with any param' do
        let(:params) { {} }

        it 'returns all the experts' do
          expect(expert_search_service.execute).to contain_exactly(*all_experts)
        end
      end
    end

    context 'when ordering' do
      %w[name
         quick_question_rate
         one_to_one_video_call_rate
         one_to_five_video_call_rate
         extra_user_rate].each do |field|
        context "when ordering by #{field} ascending" do
          let(:params) { { order: [{ field.to_sym => 'asc' }] } }

          it 'returns the experts in ascending order' do
            expect(expert_search_service.execute.to_a).to eq([expert1, expert2])
          end
        end

        context "when ordering by #{field} descending" do
          let(:params) { { order: [{ field.to_sym => 'desc' }] } }

          it 'returns the experts in descending order' do
            expect(expert_search_service.execute.to_a).to eq([expert2, expert1])
          end
        end
      end

      context 'when ordering by quick_question_rate ascending and name ascending' do
        let!(:expert3) do
          create(:expert, :with_profile, :with_categories,
                 status: :verified,
                 user: create(:user, :with_profile,
                              first_name: 'First 3', last_name: 'Last 3'),
                 quick_question_rate: 55)
        end
        let(:params) { { order: [{ quick_question_rate: 'asc', name: 'asc' }] } }

        it 'returns the experts 1, 3, 2 in order' do
          expect(expert_search_service.execute.to_a).to eq([expert1, expert3, expert2])
        end
      end
    end

    context 'when paginating' do
      before do
        create_list(:expert, 20, :with_profile, :with_categories, status: :verified,
                                                                  user: create(:user, :with_profile))
      end

      context 'with page size set to 5' do
        let(:params) { { pagination: { per_page: 5 } } }

        it 'returns only 5 experts' do
          expect(expert_search_service.execute.to_a.size).to eq(5)
        end
      end

      context 'with page size higher than the total quantity of experts' do
        let(:params) { { pagination: { per_page: 100 } } }

        it 'returns all the experts count' do
          expect(expert_search_service.execute.to_a.size).to eq(Expert.count)
        end
      end
    end

    context 'with a non-verified expert' do
      let(:params) { {} }
      let!(:non_verified_expert) do
        create(:expert, :with_profile, :with_categories, status: :pending,
                                                         user: create(:user, :with_profile))
      end

      it 'returns the experts regardless if they are verified' do
        expect(expert_search_service.execute).to contain_exactly(expert1, expert2, non_verified_expert)
      end
    end

    context 'with experts that have not completed their profile' do
      let(:params) { {} }
      let!(:expert_without_profile) do
        create(:expert, status: :pending, user: create(:user))
      end

      it 'does not return the expert_without_profile' do
        expect(expert_search_service.execute).not_to include(expert_without_profile)
      end
    end
  end
end
