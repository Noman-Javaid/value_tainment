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
require 'rails_helper'

RSpec.describe ReschedulingRequest, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
