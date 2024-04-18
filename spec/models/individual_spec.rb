# == Schema Information
#
# Table name: individuals
#
#  id                        :uuid             not null, primary key
#  has_stripe_payment_method :boolean          default(FALSE)
#  ready_for_deletion        :boolean          default(FALSE)
#  username                  :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  stripe_customer_id        :string
#  user_id                   :bigint           not null
#
# Indexes
#
#  index_individuals_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Individual, type: :model do
  subject(:individual) { user.individual }

  let(:user) { create(:user, role: 'individual') }
  let(:user_with_profile) { build(:individual, :with_profile) }

  it 'has a valid factory' do
    expect(build(:individual)).to be_valid
    expect(user_with_profile).to be_valid
  end

  describe 'ActiveRecord associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:quick_questions).dependent(:destroy) }
    it { is_expected.to have_many(:expert_calls).dependent(:destroy) }
    it { is_expected.to have_many(:guest_in_calls) }
    it { is_expected.to have_many(:transactions).dependent(:destroy) }
  end

  describe 'validations' do
    context 'on persisted records' do # rubocop:todo RSpec/ContextWording
      subject { create(:individual) }
      it { is_expected.to validate_uniqueness_of(:username).case_insensitive }
    end
  end

  describe '#expert_calls_to_list' do
    xit 'pending'
  end
end
