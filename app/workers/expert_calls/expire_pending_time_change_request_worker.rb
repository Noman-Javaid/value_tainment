class ExpertCalls::ExpirePendingTimeChangeRequestWorker
  include Sidekiq::Worker

  def perform(*args)
    # get all the rescheduling requests
    time_change_requests = TimeChangeRequest.pending
    # check if the its pending and call time is less than 24 hours from now then mark the rescheduling request as expired.
    return unless time_change_requests.present?

    time_change_requests.each do |time_change_request|
      expert_call = time_change_request.expert_call
      remaining_time = time_change_request.new_suggested_start_time > expert_call.scheduled_time_start ? expert_call.scheduled_time_start : time_change_request.new_suggested_start_time
      time_left = (Time.parse(remaining_time.to_s) - Time.parse(Time.zone.now.to_s)) / 3600
      if time_left <= 24
        time_change_request.expired!
        # decline the call if individual is not answering.
        expert_call.decline!
        Notifications::Individuals::ExpertCallNotifier.new(expert_call).rejected_call
      end
    end
  end
end
