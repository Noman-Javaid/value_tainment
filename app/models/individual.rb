# == Schema Information
#
# Table name: individuals
#
#  id                        :uuid             not null, primary key
#  has_stripe_payment_method :boolean          default(FALSE)
#  ready_for_deletion        :boolean          default(FALSE)
#  username                  :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  stripe_customer_id        :string
#  user_id                   :bigint           not null
#
# Indexes
#
#  index_individuals_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Individual < ApplicationRecord
  ## Associations
  belongs_to :user, inverse_of: :individual
  has_many :quick_questions, dependent: :destroy
  has_many :expert_calls, dependent: :destroy
  has_many :guest_in_calls, dependent: :destroy
  has_many :expert_calls_as_guest, through: :guest_in_calls, source: :expert_call
  has_many :transactions, dependent: :destroy
  has_many :complaints, dependent: :destroy
  has_many :message_reads, as: :reader
  has_many :private_chats
  ## Validations
  delegate :first_name, :last_name, :url_picture, :email, :name, :active, :device,
           :allow_notifications, to: :user

  validates :stripe_customer_id, presence: true, if: :persisted?
  validates :username, uniqueness: { case_sensitive: false, allow_nil: true }, if: :username_changed?

  ## Callbacks
  # before_destroy :individual_deletion
  after_commit :set_stripe_customer, on: :create

  ## Scopes
  scope :active, -> { joins(:user).merge(User.active) }
  delegate :timezone, to: :user
  ## Methods and helpers
  def expert_calls_to_list
    calls_as_owner = expert_calls.scheduled.coming_events
                                 .or(expert_calls.ongoing)
                                 .or(expert_calls.requires_confirmation.coming_events)
                                 .or(expert_calls.requires_time_change_confirmation.coming_events)
                                 .or(expert_calls.requires_reschedule_confirmation
                                                 .coming_events)
                                 .or(expert_calls.declined.coming_events)
    # calls_as_owner
    calls_as_guest = expert_calls_as_guest.scheduled.coming_events
                                          .or(expert_calls_as_guest.ongoing)
                                          .or(expert_calls_as_guest.requires_confirmation
                                                                   .coming_events)
                                          .or(expert_calls_as_guest.requires_reschedule_confirmation
                                                                   .coming_events)
                                          .or(expert_calls.requires_time_change_confirmation.coming_events)
                                          .or(expert_calls_as_guest.declined.coming_events)
    ExpertCall.union(calls_as_owner, calls_as_guest).most_recent
  end

  private

  # creates a stripe customer and assigns the stripe_customer_id
  def set_stripe_customer
    return if stripe_customer_id.present?

    stripes_individual_handler.create_customer
  end

  def stripes_individual_handler
    @stripes_individual_handler ||= Stripes::IndividualHandler.new(self)
  end

  def individual_deletion
    return if ready_for_deletion

    individual_deletion_set = Individuals::Accounts::DeletionSetUp.call(self)
    customer = stripes_individual_handler.delete_customer if individual_deletion_set
    update!(ready_for_deletion: customer.deleted) if customer&.deleted
    return if ready_for_deletion

    errors.add(:base, 'Individual has pending transactions')
    # check value of ready_for_deletion
    # check deletion setup service for individual
    # deattach/delete individual from remaining associations ex. quick_questions, expert_calls, transactions, complaints
    # delete customer info from stripe
    # destroy individual
  end
end
