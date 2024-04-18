# == Schema Information
#
# Table name: transactions
#
#  id                    :bigint           not null, primary key
#  amount                :integer          not null
#  charge_type           :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  expert_id             :uuid             not null
#  expert_interaction_id :bigint
#  individual_id         :uuid             not null
#  payment_id            :uuid
#  stripe_transaction_id :string           not null
#  time_addition_id      :uuid
#
# Indexes
#
#  index_transactions_on_payment_id  (payment_id)
#
# Foreign Keys
#
#  fk_rails_...  (expert_id => experts.id)
#  fk_rails_...  (expert_interaction_id => expert_interactions.id)
#  fk_rails_...  (individual_id => individuals.id)
#  fk_rails_...  (payment_id => payments.id)
#
require 'rails_helper'

RSpec.describe Transaction, type: :model do
  let(:user) { create(:user, role: 'individual') }
  let(:user_with_profile) { build(:individual, :with_profile) }

  describe 'ActiveRecord associations' do
    it { is_expected.to belong_to(:expert) }
    it { is_expected.to belong_to(:individual) }
    it { is_expected.to belong_to(:expert_interaction) }
  end

  context 'with a valid factory' do
    it { expect(build(:transaction)).to be_valid }
    it { expect(build(:transaction, :with_expert_call)).to be_valid }
  end
end
