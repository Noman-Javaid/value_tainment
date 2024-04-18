module TimeAdditions
  # state machine for time_additions
  module StateMachine
    extend ActiveSupport::Concern

    included do
      include AASM

      aasm column: :status do
        state :pending, intial: true
        state :confirmed, :declined, :transferred, :refunded, :untransferred, :unrefunded

        event :confirm, after: [:add_time_addition_rate_to_expert_pending_events, :execute_payment_capture] do
          transitions from: :pending, to: :confirmed
        end

        event :decline do
          transitions from: :pending, to: :declined
        end

        event :transfer do
          transitions from: :confirmed, to: :transferred
        end

        event :refund, after: :subtract_time_addition_rate_to_expert_pending_events do
          transitions from: :confirmed, to: :refunded, guard: :successful_refund?
        end

        event :set_refund, after: :subtract_time_addition_rate_to_expert_pending_events do
          transitions from: %i[confirmed unrefunded], to: :refunded
        end

        event :untransfer do
          transitions from: :confirmed, to: :untransferred
        end

        event :unrefund do
          transitions from: :confirmed, to: :unrefunded
        end

        event :set_as_transfer do
          transitions from: :untransferred, to: :transferred
        end
      end
    end
  end
end
