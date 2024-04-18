module Accounts::DeletionSetUpHelper
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def call(...)
      new(...).call
    end
  end

  private

  def set_interactions
    # TODO- Update account deletion flow to adjust to payment upfront flow
    # redefine which interaction requires transfers & refunds (update transaction history)
    @ongoing_calls = @user_profile.expert_calls.ongoing
    @questions_to_delete = @user_profile.quick_questions.pending_for_completion
    @questions_to_process = @user_profile.quick_questions.pending_for_payment_process
    @calls_to_delete = @user_profile.expert_calls.pending_for_completion
    @calls_to_process = @user_profile.expert_calls.pending_for_payment_process
  end

  # quick_questions total states: 11
  # [answered denied_complaint filed_complaint approved_complaint] - 4 states, to check for pending payments
  # [pending draft_answered expired failed] - 4 states, to cancel/delete interaction
  # [transfered refunded untransferred] - 3 states, no action
  def check_quick_questions
    # TODO- Update account deletion flow, refund instead of deletion
    Interactions::DeletionHelper.call(@questions_to_delete, @as_individual)
    # TODO- Update account deletion flow, transfer instead of payment
    Interactions::PaymentExecutionHelper.call(@questions_to_process, @as_individual)
  end

  # expert_calls total states: 15
  # [ongoing] - 1 state to close calls and procede to payments
  # [finished denied_complaint filed_complaint approved_complaint] - 4 states to check for pending payments
  # [requires_confirmation requires_reschedule_confirmation scheduled expired declined failed incompleted] - 7 states to cancel/delete interaction
  # [transfered refunded untransferred] - 3 no action
  def check_expert_calls
    # TODO- Update account deletion flow, refund instead of deletion
    Interactions::DeletionHelper.call(@calls_to_delete, @as_individual)
    # TODO- Update account deletion flow, transfer instead of payment
    Interactions::PaymentExecutionHelper.call(@calls_to_process, @as_individual)
  end

  def quick_questions_completed?
    (@questions_to_delete.reload.count + @questions_to_process.reload.count).zero?
  end

  def expert_calls_completed?
    (@calls_to_delete.reload.count + @calls_to_process.reload.count +
     @ongoing_calls.reload.count).zero?
  end
end
