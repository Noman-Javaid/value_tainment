# frozen_string_literal: true

class Expert::Calls::PassedList
  prepend SimpleCommand

  attr_accessor :expert

  def initialize(expert)
    @expert = expert
  end

  def call
    # get the passed calls list, this includes on-going calls as well.
    expert.expert_calls.passed_events.not_expired.not_declined.latest_passed
  end
end
