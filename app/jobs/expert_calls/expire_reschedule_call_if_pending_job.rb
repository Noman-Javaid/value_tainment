module ExpertCalls
  class ExpireRescheduleCallIfPendingJob < ApplicationJob
    queue_as :default

    def perform(request_id)
      rescheduling_request = ReschedulingRequest.find(request_id)
      # check if the its pending and call time is less than 24 hours from now then mark the rescheduling request as expired.
      return unless rescheduling_request.present?

      return unless rescheduling_request.pending?

      expert_call = rescheduling_request.expert_call
      remaining_time = rescheduling_request.new_requested_start_time > expert_call.scheduled_time_start ? expert_call.scheduled_time_start : rescheduling_request.new_requested_start_time
      time_left = (Time.parse(remaining_time.to_s) - Time.parse(Time.zone.now.to_s)) / 3600
      return if time_left > 24

      rescheduling_request.expired!

      case rescheduling_request.rescheduled_by
      when Individual
        expert_call.update(call_status: 'scheduled')
      when Expert
        rescheduling_request.expired!
        # cancel the call if individual is not answering within time.
        Expert::Calls::Cancel.call(expert_call.expert, expert_call, I18n.t('api.expert_call.cancellation.cancel_on_not_answering_rescheduling_request'))
      end
    end
  end
end
