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

class ReschedulingRequest < ApplicationRecord
  enum status: { pending: 'pending', accepted: 'accepted', declined: 'declined', expired: 'expired' }
  belongs_to :rescheduled_by, polymorphic: true, optional: true
  belongs_to :expert_call

  after_create :enqueue_expire_pending_request_job

  private

  def enqueue_expire_pending_request_job
    remaining_time = new_requested_start_time > expert_call.scheduled_time_start ? expert_call.scheduled_time_start : new_requested_start_time
    ExpertCalls::ExpireRescheduleCallIfPendingJob.set(
      wait_until: 1.day.ago(remaining_time)
    ).perform_later(id)
  end
end
