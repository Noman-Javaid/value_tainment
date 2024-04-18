# == Schema Information
#
# Table name: rescheduling_requests
#
#  id                       :uuid             not null, primary key
#  new_requested_start_time :datetime
#  rescheduled_by_type      :string
#  rescheduling_reason      :string(1000)
#  status                   :string           default("pending")
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  expert_call_id           :uuid
#  rescheduled_by_id        :uuid
#
# Indexes
#
#  index_rescheduling_requests_on_expert_call_id  (expert_call_id)
#  index_rescheduling_requests_on_rescheduled_by  (rescheduled_by_type,rescheduled_by_id)
#
FactoryBot.define do
  factory :rescheduling_request do
    
  end
end
