# frozen_string_literal: true

class Expert::Calls::AllList
  prepend SimpleCommand

  attr_accessor :expert

  def initialize(expert)
    @expert = expert
  end

  def call
    # get the all the calls list
    expert.expert_calls.most_recent

  end
end
