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
FactoryBot.define do
  factory :alert do
    alertable { create(:expert_call) }
    message { "An error has accurred with the Expert Call" }
    alert_type { :refund }
    note { "Sample note" }
    status { "pending" }
  end
end
