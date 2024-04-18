# == Schema Information
#
# Table name: transfers
#
#  id                         :bigint           not null, primary key
#  amount                     :integer
#  balance_transaction_id_ext :string
#  destination_account_id_ext :string
#  destination_payment_id_ext :string
#  reversed                   :boolean
#  transfer_id_ext            :string
#  transfer_metadata          :jsonb            not null
#  transferable_type          :string           not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  transferable_id            :uuid             not null
#
require 'rails_helper'

RSpec.describe Transfer, type: :model do
  subject { build(:transfer, :with_metadata) }

  it 'has a valid factory' do
    expect(subject).to be_valid # rubocop:todo RSpec/NamedSubject
  end

  describe 'associations' do
    it { is_expected.to belong_to(:transferable) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_numericality_of(:amount).only_integer }
    it { is_expected.to validate_presence_of(:balance_transaction_id_ext) }
    it { is_expected.to validate_presence_of(:destination_account_id_ext) }
    it { is_expected.to validate_presence_of(:destination_payment_id_ext) }
    it { is_expected.to validate_presence_of(:transfer_id_ext) }
    it { is_expected.to validate_presence_of(:transfer_metadata) }
  end
end
