# frozen_string_literal: true

class Expert::Calls::UpcomingList
  prepend SimpleCommand

  attr_accessor :expert

  def initialize(expert)
    @expert = expert
  end

  def call
    # get the upcoming calls list
    (expert.expert_calls.scheduled.coming_events.or(expert.expert_calls.ongoing.coming_events)).most_recent
  end
end
