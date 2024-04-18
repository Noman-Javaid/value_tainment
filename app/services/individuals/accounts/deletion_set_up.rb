class Individuals::Accounts::DeletionSetUp
  AS_INDIVIDUAL = true
  include Accounts::DeletionSetUpHelper

  def initialize(user_profile)
    @user_profile = user_profile
    @as_individual = AS_INDIVIDUAL
  end

  # service to check if the user_profile has no pending or active transactions before deletion
  def call
    return true unless @user_profile

    close_ongoing_calls
    set_interactions
    # check the pending_for_completion and pending_for_payments interactions
    check_quick_questions
    check_expert_calls
    quick_questions_completed? && expert_calls_completed? &&
      deattach_related_associations?
  end

  private

  def close_ongoing_calls
    @user_profile.expert_calls.ongoing.each do |ongoing_call|
      ExpertCalls::CallFinisher.new(ongoing_call).call
    end
  end

  def deattach_transactions
    Individuals::DeattachAssociationsHelper.call(@user_profile, :transactions)
  end

  def deattach_complaints
    Individuals::DeattachAssociationsHelper.call(@user_profile, :complaints)
  end

  def deattach_guest_in_calls
    Individuals::DeattachAssociationsHelper.call(@user_profile, :guest_in_calls)
  end

  def deattach_expert_calls
    Individuals::DeattachAssociationsHelper.call(@user_profile, :expert_calls)
  end

  def deattach_quick_questions
    Individuals::DeattachAssociationsHelper.call(@user_profile, :quick_questions)
  end

  def deattach_related_associations?
    deattach_quick_questions && deattach_expert_calls && deattach_guest_in_calls
    deattach_complaints && deattach_transactions
  end
end
