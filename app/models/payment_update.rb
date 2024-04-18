# == Schema Information
#
# Table name: payment_updates
#
#  id         :uuid             not null, primary key
#  changes    :json
#  status     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  payment_id :uuid             not null
#
# Indexes
#
#  index_payment_updates_on_payment_id  (payment_id)
#
# Foreign Keys
#
#  fk_rails_...  (payment_id => payments.id)
#
class PaymentUpdate < ApplicationRecord
  belongs_to :payment
end
