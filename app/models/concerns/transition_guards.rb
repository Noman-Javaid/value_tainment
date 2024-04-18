module TransitionGuards
  extend ActiveSupport::Concern

  def both_users_are_active?
    return false if individual.nil? || expert.nil?

    individual.active && expert.active
  end
end
