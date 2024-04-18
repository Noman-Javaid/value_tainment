module ExpertCalls
  class UpdateCallToFinishJob < ApplicationJob
    queue_as :default

    def perform
      expert_calls = ExpertCall.ongoing.time_left_off
      finish_calls(expert_calls)
    end
  end
end
