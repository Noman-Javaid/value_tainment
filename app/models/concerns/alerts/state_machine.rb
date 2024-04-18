module Alerts
  # state machine for expert_calls
  module StateMachine
    extend ActiveSupport::Concern

    included do
      include AASM

      aasm column: :status, whiny_persistance: true do
        state :pending, intial: true
        state :in_progress, :resolved

        event :process do
          transitions from: :pending, to: :in_progress
        end

        event :resolve do
          transitions from: %i[pending in_progress], to: :resolved
        end
      end
    end
  end
end
