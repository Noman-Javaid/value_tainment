# == Schema Information
#
# Table name: payments
#
#  id                   :uuid             not null, primary key
#  amount               :decimal(, )
#  currency             :string
#  payable_type         :string           not null
#  payment_method_types :string           default(["\"card\""]), is an Array
#  payment_provider     :string           default("stripe")
#  status               :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  payable_id           :uuid             not null
#  payment_id           :string
#  payment_method_id    :string
#
# Indexes
#
#  index_payments_on_payable  (payable_type,payable_id)
#
class Payment < ApplicationRecord
  self.implicit_order_column = :created_at

  belongs_to :payable, polymorphic: true
  has_many :refunds, dependent: :destroy, as: :refundable
  has_many :payment_updates, dependent: :destroy
  has_one :related_transaction, class_name: 'Transaction'

  enum status: { pending: 'pending', requires_capture: 'requires_capture', captured: 'captured', failed: 'failed', refunded: 'refunded', released: 'released', transferred: 'transferred' }

  before_create :set_defaults
  after_update :create_payment_update_record

  private

  def create_payment_update_record
    changes_to_track = self.changes.reject { |k, _v| k == "updated_at" }
    return if changes_to_track.blank?

    PaymentUpdate.create(payment: self, changes: changes_to_track, status: self.status)
  end

  def set_defaults
    self.currency = 'USD'
    self.status = 'pending'
    self.payment_provider = 'stripe'
  end
end
