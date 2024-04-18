# == Schema Information
#
# Table name: guest_in_calls
#
#  id             :bigint           not null, primary key
#  confirmed      :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  expert_call_id :uuid             not null
#  individual_id  :uuid             not null
#
# Foreign Keys
#
#  fk_rails_...  (expert_call_id => expert_calls.id)
#  fk_rails_...  (individual_id => individuals.id)
#
require 'rails_helper'

RSpec.describe GuestInCall, type: :model do
  subject { build(:guest_in_call) }

  describe 'associations' do
    it { is_expected.to belong_to(:expert_call) }
    it { is_expected.to belong_to(:individual) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:expert_call) }
    it { is_expected.to validate_presence_of(:individual) }

    describe 'limit_guest_count' do
      let(:expert) { create(:expert, :with_profile, status: :verified) }
      let(:individual) { create(:user, :with_profile).individual }
      let(:expert_call) { create(:expert_call, :ongoing, individual: individual, expert: expert) }
      let(:guest_in_call) { described_class.new(expert_call: expert_call, individual: individual) }

      context 'when raised max guest limit' do
        before do
          create_list(:guest_in_call, 58, expert_call: expert_call, individual: create(:user, :with_profile).individual)
          guest_in_call.valid?
        end

        it { expect(guest_in_call.errors.full_messages).to eq(['Individual max limit guest count raised']) }
      end

      context 'when valid guest limit' do
        before do
          create_list(:guest_in_call, 57, expert_call: expert_call, individual: create(:user, :with_profile).individual)
          guest_in_call.valid?
        end

        it { expect(guest_in_call).to be_valid }
      end
    end
  end
end
