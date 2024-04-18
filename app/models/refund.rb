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
class Refund < ApplicationRecord
  belongs_to :refundable, polymorphic: true

  validates :amount, presence: true, numericality: { only_integer: true }
  validates :payment_intent_id_ext, presence: true
  validates :refund_id_ext, presence: true
  validates :refund_metadata, presence: true
  validates :status, presence: true
end
