module ExpertCalls
  class RemoveOldCallsJob < ApplicationJob
    queue_as :default

    def perform(*_args)
      ongoing_expert_calls = ExpertCall.ongoing.where(
        'scheduled_time_end < ?', 1.minute.from_now
      )

      ongoing_expert_calls.each do |ongoing_call|
        ExpertCalls::CloseOngoingCall.new(ongoing_call).call
      end
    end
  end
end
