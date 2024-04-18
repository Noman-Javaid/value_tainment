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
class Transfer < ApplicationRecord
  belongs_to :transferable, polymorphic: true

  validates :amount, presence: true, numericality: { only_integer: true}
  validates :balance_transaction_id_ext, presence: true
  validates :destination_account_id_ext, presence: true
  validates :destination_payment_id_ext, presence: true
  validates :transfer_id_ext, presence: true
  validates :transfer_metadata, presence: true
end
