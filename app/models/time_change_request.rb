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
class TimeChangeRequest < ApplicationRecord
  enum status: { pending: 'pending', accepted: 'accepted', declined: 'declined', expired: 'expired' }
  belongs_to :requested_by, polymorphic: true, optional: true
  belongs_to :expert_call

  after_create :enqueue_expire_pending_request_job

  private

  def enqueue_expire_pending_request_job
    remaining_time = new_suggested_start_time > expert_call.scheduled_time_start ? expert_call.scheduled_time_start : new_suggested_start_time

    ExpertCalls::ExpireTimeChangeRequestIfPendingJob.set(
      wait_until: 1.day.ago(remaining_time)
    ).perform_later(id)
  end
end
