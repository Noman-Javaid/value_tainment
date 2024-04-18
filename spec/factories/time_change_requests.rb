# == Schema Information
#
# Table name: time_change_requests
#
#  id                       :uuid             not null, primary key
#  new_suggested_start_time :datetime
#  reason                   :string(1000)
#  requested_by_type        :string
#  status                   :string           default("pending")
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  expert_call_id           :uuid
#  requested_by_id          :uuid
#
# Indexes
#
#  index_time_change_requests_on_expert_call_id  (expert_call_id)
#  index_time_change_requests_on_requested_by    (requested_by_type,requested_by_id)
#
FactoryBot.define do
  factory :time_change_request do
    
  end
end
