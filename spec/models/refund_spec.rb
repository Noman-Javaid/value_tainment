# == Schema Information
#
# Table name: refunds
#
#  id                    :bigint           not null, primary key
#  amount                :integer
#  payment_intent_id_ext :string
#  refund_id_ext         :string
#  refund_metadata       :jsonb            not null
#  refundable_type       :string           not null
#  status                :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  refundable_id         :uuid             not null
#
require 'rails_helper'

RSpec.describe Refund, type: :model do
  subject { build(:refund, :with_metadata) }

  it 'has a valid factory' do
    expect(subject).to be_valid # rubocop:todo RSpec/NamedSubject
  end

  describe 'associations' do
    it { is_expected.to belong_to(:refundable) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_numericality_of(:amount).only_integer }
    it { is_expected.to validate_presence_of(:payment_intent_id_ext) }
    it { is_expected.to validate_presence_of(:refund_id_ext) }
    it { is_expected.to validate_presence_of(:refund_metadata) }
    it { is_expected.to validate_presence_of(:status) }
  end
end
