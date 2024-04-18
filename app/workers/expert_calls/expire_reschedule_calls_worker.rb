class ExpertCalls::ExpireRescheduleCallsWorker
  include Sidekiq::Worker

  def perform
    # get all the rescheduling requests
    rescheduling_requests = ReschedulingRequest.pending
    # check if the its pending and call time is less than 24 hours from now then mark the rescheduling request as expired.
    return unless rescheduling_requests.present?

    rescheduling_requests.each do |rescheduling_request|
      expert_call = rescheduling_request.expert_call
      time_left = (Time.parse(expert_call.scheduled_time_start.to_s) - Time.parse(Time.zone.now.to_s)) / 3600
      next unless time_left <= 24

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
