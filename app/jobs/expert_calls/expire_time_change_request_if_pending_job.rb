module ExpertCalls
  class ExpireTimeChangeRequestIfPendingJob < ApplicationJob
    queue_as :default

    def perform(request_id)
      time_change_request = TimeChangeRequest.find(request_id)

      return unless time_change_request.present?

      return unless time_change_request.pending?

      expert_call = time_change_request.expert_call

      time_change_request.expired!

      expert_call.decline!
      Notifications::Individuals::ExpertCallNotifier.new(expert_call).rejected_call
    end
  end
end
