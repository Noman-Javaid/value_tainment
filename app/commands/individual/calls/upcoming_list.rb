# frozen_string_literal: true

class Individual::Calls::UpcomingList
  prepend SimpleCommand

  attr_accessor :individual

  def initialize(individual)
    @individual = individual
  end

  def call
    # get the upcoming calls list except rejected/declined ones
    individual.expert_calls.coming_events.most_recent
  end
end
