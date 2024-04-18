module ExpertCalls
  # state machine for expert_calls
  module StateMachine
    extend ActiveSupport::Concern

    included do
      include AASM

      aasm column: :call_status, whiny_persistance: true do
        state :requires_confirmation, initial: true
        state :scheduled, :declined, :requires_reschedule_confirmation, :requires_time_change_confirmation, :expired,
              :ongoing, :finished, :incompleted, :transfered, :refunded, :failed,
              :filed_complaint, :approved_complaint, :denied_complaint, :untransferred,
              :unrefunded, :unrefunded_for_incompleted_event, :cancelled

        event :schedule, after: :execute_payment_capture do
          transitions from: :requires_confirmation, to: :scheduled, guard: :both_users_are_active?
        end

        event :set_as_requires_reschedule_confirmation do
          transitions from: %i[scheduled requires_confirmation], to: :requires_reschedule_confirmation, guard: :both_users_are_active?
        end

        event :set_as_requires_time_change_confirmation do
          transitions from: %i[scheduled requires_confirmation], to: :requires_time_change_confirmation, guard: :both_users_are_active?
        end

        event :expire do
          transitions from: %i[requires_confirmation requires_reschedule_confirmation requires_time_change_confirmation],
                      to: :expired
        end

        event :reschedule do
          transitions from: :requires_reschedule_confirmation, to: :scheduled, guard: :both_users_are_active?
        end

        event :time_change do
          transitions from: :requires_time_change_confirmation, to: :scheduled, guard: :both_users_are_active?
        end

        event :decline do
          transitions from: %i[requires_confirmation requires_reschedule_confirmation requires_time_change_confirmation],
                      to: :declined, guard: :both_users_are_active?
        end

        event :cancel, after: :successful_refund? do
          transitions from: %i[requires_confirmation requires_reschedule_confirmation requires_time_change_confirmation scheduled declined failed incompleted],
                      to: :cancelled, guard: :both_users_are_active?
        end

        event :fail do
          transitions from: :scheduled, to: :failed
        end

        event :set_as_ongoing do
          transitions from: :scheduled, to: :ongoing, guard: :both_users_are_active?
        end

        event :finish, after: :add_rate_to_expert_pending_events do
          transitions from: :ongoing, to: :finished
        end

        event :set_as_incompleted do
          transitions from: :ongoing, to: :incompleted
        end

        event :transfer do
          transitions from: %i[finished denied_complaint], to: :transfered,
                      guard: :successful_transfer?
        end

        event :refund, after: :subtract_rate_to_expert_pending_events do
          transitions from: %i[finished approved_complaint cancelled], to: :refunded,
                      guard: :successful_refund?
        end

        # do not require callback for account balance update
        event :set_as_refunded do
          transitions from: %i[declined failed incompleted expired cancelled], to: :refunded,
                      guard: :successful_refund?
        end

        event :set_as_filed_complaint do
          transitions from: %i[scheduled ongoing finished], to: :filed_complaint
        end

        event :set_as_approved_complaint do
          transitions from: :filed_complaint, to: :approved_complaint
        end

        event :set_as_denied_complaint do
          transitions from: :filed_complaint, to: :denied_complaint
        end

        event :untransfer do
          transitions from: [:finished, :denied_complaint], to: :untransferred
        end

        event :set_as_unrefunded do
          transitions from: %i[declined failed incompleted expired],
                      to: :unrefunded_for_incompleted_event
        end

        event :unrefund do
          transitions from: %i[finished approved_complaint], to: :unrefunded
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
