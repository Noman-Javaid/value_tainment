# frozen_string_literal: true

class Individual::Calls::PassedList
  prepend SimpleCommand

  attr_accessor :individual

  def initialize(individual)
    @individual = individual
  end

  def call
    # get the passed calls list, this includes on-going calls as well.
    individual.expert_calls.passed_events.latest_passed
  end
end
