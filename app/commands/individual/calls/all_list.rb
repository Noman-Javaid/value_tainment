# frozen_string_literal: true

class Individual::Calls::AllList
  prepend SimpleCommand

  attr_accessor :individual

  def initialize(individual)
    @individual = individual
  end

  def call
    # get the all the calls list
    individual.expert_calls.most_recent
  end
end
