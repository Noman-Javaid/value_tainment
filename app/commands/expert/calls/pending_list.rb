# frozen_string_literal: true

class Expert::Calls::PendingList
  prepend SimpleCommand

  attr_accessor :expert

  def initialize(expert)
    @expert = expert
  end

  def call
    # get the pending calls list
    expert.expert_calls.requires_confirmation.coming_events
          .or(expert.expert_calls.requires_reschedule_confirmation.coming_events)
          .or(expert.expert_calls.requires_time_change_confirmation.coming_events)
          .most_recent
  end
end
