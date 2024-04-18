class Experts::Accounts::DeletionSetUp
  AS_INDIVIDUAL = false
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
    quick_questions_completed? && expert_calls_completed? && pending_payouts_completed? &&
      deattach_related_associations?
  end

  private

  def close_ongoing_calls
    @user_profile.expert_calls.ongoing.each do |ongoing_call|
      ongoing_call.update(payment_id: nil) if ongoing_call.payment_id
      ExpertCalls::CallFinisher.new(ongoing_call).call
    end
  end

  def deattach_transactions
    Experts::DeattachAssociationsHelper.call(@user_profile, :transactions)
  end

  def deattach_complaints
    Experts::DeattachAssociationsHelper.call(@user_profile, :complaints)
  end

  def deattach_expert_calls
    Experts::DeattachAssociationsHelper.call(@user_profile, :expert_calls)
  end

  def deattach_quick_questions
    Experts::DeattachAssociationsHelper.call(@user_profile, :quick_questions)
  end

  def deattach_related_associations?
    deattach_quick_questions && deattach_expert_calls && deattach_complaints &&
      deattach_transactions
  end

  def pending_payouts_completed?
    return true if @user_profile.stripe_account_id.blank?

    balance = Stripes::ExpressAccounts::BalanceRetriever.call(@user_profile)
    return false if balance.nil? || balance.respond_to?(:error)

    with_zero_balance?(balance)
  end

  def with_zero_balance?(balance)
    zero_pending_payouts?(balance) && zero_available_payouts?(balance) &&
      zero_instant_available_payouts?(balance) && zero_connect_reserved_payouts?(balance)
  end

  def zero_pending_payouts?(balance)
    balance.pending.map(&:amount).sum.zero?
  end

  def zero_available_payouts?(balance)
    balance.available.map(&:amount).sum.zero?
  end

  def zero_instant_available_payouts?(balance)
    balance.instant_available.map(&:amount).sum.zero?
  end

  def zero_connect_reserved_payouts?(balance)
    return true unless balance.respond_to?(:connect_reserved)

    balance.connect_reserved.map(&:amount).sum.zero?
  end
end
