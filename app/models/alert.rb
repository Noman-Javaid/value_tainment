# == Schema Information
#
# Table name: alerts
#
#  id             :bigint           not null, primary key
#  alert_type     :integer
#  alertable_type :string           not null
#  message        :string
#  note           :string
#  status         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  alertable_id   :uuid             not null
#
class Alert < ApplicationRecord
  include Alerts::StateMachine

  enum alert_type: { refund: 0, transfer: 1, payment_captured: 2, release_captured_payment: 3 }

  belongs_to :alertable, polymorphic: true

  validates :alert_type, presence: true
  validates :message, presence: true
end
