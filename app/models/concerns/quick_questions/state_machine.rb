module QuickQuestions
  # state machine for quick_questions
  module StateMachine
    extend ActiveSupport::Concern

    included do
      include AASM

      aasm column: :status, whiny_persistance: true do
        state :pending, intial: true
        state :expired, :answered, :draft_answered, :transfered, :refunded, :failed,
              :filed_complaint, :approved_complaint, :denied_complaint, :untransferred,
              :unrefunded, :unrefunded_for_incompleted_event

        event :expire do
          transitions from: %i[pending draft_answered], to: :expired
        end

        event :set_as_answered, after: [:add_rate_to_expert_pending_events, :execute_payment_capture] do
          transitions from: %i[pending draft_answered], to: :answered, guard: :both_users_are_active?
        end

        event :set_as_draft_answered do
          transitions from: :pending, to: :draft_answered, guard: :both_users_are_active?
        end

        event :transfer do
          transitions from: %i[answered denied_complaint], to: :transfered,
                      guard: :successful_transfer?
        end

        # require callback for account balance update
        event :refund, after: :subtract_rate_to_expert_pending_events do
          transitions from: %i[answered approved_complaint], to: :refunded,
                      guard: :successful_refund?
        end

        # do not require callback for account balance update
        event :set_as_refunded do
          transitions from: :expired, to: :refunded, guard: :successful_refund?
        end

        event :set_as_filed_complaint do
          transitions from: %i[answered], to: :filed_complaint
        end

        event :set_as_approved_complaint do
          transitions from: :filed_complaint, to: :approved_complaint
        end

        event :set_as_denied_complaint do
          transitions from: :filed_complaint, to: :denied_complaint
        end

        event :untransfer do
          transitions from: %i[answered denied_complaint], to: :untransferred
        end

        event :unrefund do
          transitions from: %i[answered approved_complaint], to: :unrefunded
        end

        event :set_as_unrefunded do
          transitions from: :expired, to: :unrefunded_for_incompleted_event
        end

        event :set_as_transfer do
          transitions from: :untransferred, to: :transfered
        end

        event :set_refund_for_incompleted_event do
          transitions from: :unrefunded_for_incompleted_event, to: :refunded
        end

        event :set_refund, after: :subtract_rate_to_expert_pending_events do
          transitions from: :unrefunded, to: :refunded
        end
      end
    end
  end
end
