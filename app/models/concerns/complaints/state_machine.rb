module Complaints
  module StateMachine
    extend ActiveSupport::Concern

    included do
      include AASM

      aasm column: :status do
        state :requires_verification, intial: true
        state :denied, :approved

        event :approve do
          transitions from: :requires_verification, to: :approved
        end

        event :deny do
          transitions from: :requires_verification, to: :denied
        end
      end
    end
  end
end
