require 'rails_helper'

describe ExpertCalls::MinuteCostCalculation do
  include_context 'users_for_expert_endpoints'

  let(:one_to_one_video_call_rate) { 10 }
  let(:video_call_rate) { 10 }
  let(:one_to_five_video_call_rate) { 20 }
  let(:extra_user_rate) { 10 }
  let(:expert_call) do
    build(:expert_call, :with_1to5, expert: expert, individual: individual,
                                    guest_ids: guest_ids)
  end

  describe '#call' do
    before do
      expert.update!(
        one_to_one_video_call_rate: one_to_one_video_call_rate,
        video_call_rate: video_call_rate,
        one_to_five_video_call_rate: one_to_five_video_call_rate,
        extra_user_rate: extra_user_rate
      )
    end

    context 'with expert call type 1:1' do
      let(:expert_call) do
        build(:expert_call, expert: expert, individual: individual)
      end
      let(:expected_result) { video_call_rate }

      it 'match the expected result' do
        expect(described_class.new(expert_call).call).to eq(expected_result)
      end
    end

    context 'with expert call type 1:5 with 1 guest' do
      let(:guest_ids) { [create(:individual, :with_profile).id] }
      let(:expected_result) { one_to_five_video_call_rate }

      it 'match the expected result' do
        expect(described_class.new(expert_call).call).to eq(expected_result)
      end
    end

    context 'with expert call type 1:5 with 2 guests' do
      let(:guest_ids) { create_list(:individual, 2, :with_profile).map(&:id) }
      let(:expected_result) { one_to_five_video_call_rate }

      it 'match the expected result' do
        expect(described_class.new(expert_call).call).to eq(expected_result)
      end
    end

    context 'with expert call type 1:5 with 3 guests' do
      let(:guest_ids) { create_list(:individual, 3, :with_profile).map(&:id) }
      let(:expected_result) { one_to_five_video_call_rate }

      it 'match the expected result' do
        expect(described_class.new(expert_call).call).to eq(expected_result)
      end
    end

    context 'with expert call type 1:5 with 4 guests' do
      let(:guest_ids) { create_list(:individual, 4, :with_profile).map(&:id) }
      let(:expected_result) { one_to_five_video_call_rate }

      it 'match the expected result' do
        expect(described_class.new(expert_call).call).to eq(expected_result)
      end
    end

    context 'with expert call type 1:5 with 5 guests a.k.a 1 extra user' do
      let(:guest_ids) { create_list(:individual, 5, :with_profile).map(&:id) }
      let(:expected_result) { one_to_five_video_call_rate + extra_user_rate }

      it 'match the expected result' do
        expect(described_class.new(expert_call).call).to eq(expected_result)
      end
    end

    context 'with expert call type 1:5 with 6 guests a.k.a 2 extra users' do
      let(:guest_ids) { create_list(:individual, 6, :with_profile).map(&:id) }
      let(:expected_result) { one_to_five_video_call_rate + (extra_user_rate * 2) }

      it 'match the expected result' do
        expect(described_class.new(expert_call).call).to eq(expected_result)
      end
    end
  end
end
