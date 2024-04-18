module PaymentScopes
  extend ActiveSupport::Concern

  included do
    scope :with_payment, -> { where.not(payment_id: nil) }
    scope :with_payment_success, -> { where(payment_status: 'succeeded') }
  end
end
