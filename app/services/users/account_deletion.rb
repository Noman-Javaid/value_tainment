class Users::AccountDeletion
  def initialize(user)
    @user = user
  end

  def self.call(...)
    new(...).call
  end

  def call
    return unless @user

    set_profiles
    update_user_inactivity
    create_follow_up
    individual_deletion if @individual
    expert_deletion if @expert
    user_deletion
  end

  private

  def update_user_inactivity
    return if @user.account_deletion_requested_at

    @user.update!(
      account_deletion_requested_at: Time.current, allow_notifications: false, active: false
    )
  end

  def individual_deletion
    return if @individual.ready_for_deletion

    @individual_deletion_setup = Individuals::Accounts::DeletionSetUp.call(@individual)
    unless @individual_deletion_setup
      required_for_individual_as_true
      return
    end

    customer = Stripes::IndividualHandler.new(@individual).delete_customer
    @individual.update!(ready_for_deletion: customer.deleted) if customer
  end

  def expert_deletion
    return if @expert.ready_for_deletion

    @expert_deletion_setup = Experts::Accounts::DeletionSetUp.call(@expert)
    unless @expert_deletion_setup
      required_for_expert_as_true
      return
    end
    return @expert.update!(ready_for_deletion: true) if @expert.stripe_account_id.blank?

    Stripes::ExpressAccounts::DeletionHandler.call(@expert)
  end

  def user_deletion
    return unless profile_ready_for_deletion?(@individual) &&
                  profile_ready_for_deletion?(@expert)

    delete_user
  end

  def delete_user
    update_follow_up_as_resolved
    @user.destroy!
    UserAccountDeletionMailer.send_to(@user.email, @user.name).deliver_now
  end

  def set_profiles
    @individual = @user.individual
    @expert = @user.expert
  end

  def profile_ready_for_deletion?(user_profile)
    return true if user_profile.nil? || user_profile.ready_for_deletion

    false
  end

  def create_follow_up
    return if account_deletion_follow_up

    @account_deletion_follow_up = AccountDeletionFollowUp.create!(
      user: @user,
      required_for_individual: false,
      required_for_expert: false,
      stripe_customer_id: @individual&.stripe_customer_id,
      stripe_account_id: @expert&.stripe_account_id,
      status: 'created'
    )
  end

  def update_follow_up_as_resolved
    return if account_deletion_follow_up.nil?

    AccountDeletionFollowUps::TrackerHelper.call(
      @user, AccountDeletionFollowUp::RESOLVED_NOTE
    )
    account_deletion_follow_up.update!(
      required_for_individual: false,
      required_for_expert: false,
      status: 'resolved'
    )
  end

  def account_deletion_follow_up
    @account_deletion_follow_up ||= @user.account_deletion_follow_up
  end

  # rubocop:disable Style/GuardClause
  def required_for_individual_as_true
    unless account_deletion_follow_up.required_for_individual
      account_deletion_follow_up.update!(
        required_for_individual: true, status: 'requires_revision'
      )
    end
  end

  def required_for_expert_as_true
    unless account_deletion_follow_up.required_for_expert
      account_deletion_follow_up.update!(
        required_for_expert: true, status: 'requires_revision'
      )
    end
  end
  # rubocop:enable Style/GuardClause
end
