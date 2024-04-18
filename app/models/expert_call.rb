# frozen_string_literal: true

# == Schema Information
#
# Table name: expert_calls
#
#  id                           :uuid             not null, primary key
#  call_status                  :string           default("requires_confirmation"), not null
#  call_time                    :integer          default(0), not null
#  call_type                    :string           not null
#  cancellation_reason          :string(1000)
#  cancelled_at                 :datetime
#  cancelled_by_type            :string
#  description                  :string           not null
#  guests_count                 :integer          default(0), not null
#  payment_status               :string
#  rate                         :integer          not null
#  room_creation_failure_reason :string
#  room_status                  :string           default(NULL)
#  scheduled_call_duration      :integer          default(20), not null
#  scheduled_time_end           :datetime         not null
#  scheduled_time_start         :datetime         not null
#  time_end                     :datetime
#  time_start                   :datetime
#  title                        :string           not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  cancelled_by_id              :uuid
#  category_id                  :integer
#  expert_id                    :uuid             not null
#  individual_id                :uuid             not null
#  payment_id                   :string
#  room_id                      :string
#  stripe_payment_method_id     :string
#
# Indexes
#
#  index_expert_calls_on_cancelled_by   (cancelled_by_type,cancelled_by_id)
#  index_expert_calls_on_category_id    (category_id)
#  index_expert_calls_on_expert_id      (expert_id)
#  index_expert_calls_on_individual_id  (individual_id)
#  index_expert_calls_on_room_status    (room_status)
#
# Foreign Keys
#
#  fk_rails_...  (category_id => categories.id)
#  fk_rails_...  (expert_id => experts.id)
#  fk_rails_...  (individual_id => individuals.id)
#
class ExpertCall < ApplicationRecord
  ## Inheritance
  include PaymentScopes
  include TransitionGuards
  include ActAsInteractions
  include AccountBalanceCalculation
  include ExpertCalls::StateMachine
  include ExpertActiveStateValidation

  ## Constants
  MAX_GUESTS_NUMBER = 4
  DEFAULT_HOURS_TO_ACCEPT = 168
  DEFAULT_CALL_DURATION = (ENV['DEFAULT_CALL_DURATION'] || 20).to_i # rubocop:todo Rails/EnvironmentVariableAccess
  VALID_CALL_DURATIONS = [15, 30, 45, 60].freeze
  VALID_CALL_DURATION_ARRAY = VALID_CALL_DURATIONS + [DEFAULT_CALL_DURATION]
  CALL_TYPE_ONE_TO_ONE = '1-1'
  CALL_TYPE_ONE_TO_FIVE = '1-5'
  MINUTES_ABOUT_TO_START_CALL_NOTIFICATION = 5
  MINUTES_TIME_LEFT_TO_END_CALL = 2
  TIME_LEFT_MESSAGE = "The call is going to end in #{MINUTES_TIME_LEFT_TO_END_CALL} minutes"
  TIME_LEFT_OFF_QUERY = '(EXTRACT(EPOCH FROM (NOW() - time_start))) >= (scheduled_call_duration * 60)'
  CANCELLATION_ALLOWED_FROM_STATUS = %w[requires_confirmation requires_reschedule_confirmation scheduled declined failed incompleted requires_reschedule_confirmation requires_time_change_confirmation]
  RESCHEDULING_ALLOWED_FROM_STATUS = %w[scheduled]
  TIME_CHANGED_ALLOWED_FROM_STATUS = %w[requires_confirmation]
  COMPLETED_STATUS = %w[finished transfered refunded failed filed_complaint approved_complaint denied_complaint untransferred unrefunded]
  PENDING_EARNING_STATUS = %w(requires_confirmation scheduled requires_reschedule_confirmation requires_time_change_confirmation ongoing finished filed_complaint approved_complaint denied_complaint untransferred
              unrefunded unrefunded_for_incompleted_event)

  enum room_status: {
    creation_pending: 'pending',
    creation_in_progress: 'in_progress',
    created: 'created',
    failed: 'failed'
  }

  ## Associations
  belongs_to :expert
  belongs_to :individual
  belongs_to :category, optional: true
  has_many :rescheduling_requests
  has_many :time_change_requests
  has_one :chat_room

  has_many :alerts, as: :alertable, dependent: :destroy
  has_many :guest_in_calls, dependent: :destroy
  has_many :guests, -> { active }, through: :guest_in_calls, source: :individual
  has_many :participant_events, dependent: :destroy
  has_many :refunds, as: :refundable, dependent: :destroy
  has_many :time_additions, dependent: :destroy
  has_many :transfers, as: :transferable, dependent: :destroy
  belongs_to :cancelled_by, polymorphic: true, optional: true
  ## Validations
  validates :title, presence: true, length: { maximum: 50 }
  validates :description, presence: true, length: { maximum: 2000 }
  validates :call_type, presence: true,
            inclusion: { in: [CALL_TYPE_ONE_TO_ONE, CALL_TYPE_ONE_TO_FIVE] }
  validates :scheduled_call_duration, presence: true,
            inclusion: { in: VALID_CALL_DURATION_ARRAY }
  validates :scheduled_time_start, presence: true
  validates :scheduled_time_end, presence: true
  validates :stripe_payment_method_id, presence: true
  validates :rate, presence: true
  validates :call_status, presence: true
  validates_datetime :scheduled_time_start, after: -> { Time.current },
                     after_message: 'can\'t be a passed date',
                     if: :scheduled_time_start_changed?
  validate :guest_amount_match_call_type, on: :create

  validates :cancellation_reason, length: { maximum: 1000 }
  ## Scopes
  scope :time_left_off, -> { where(TIME_LEFT_OFF_QUERY) }
  scope :coming_events, -> { where('scheduled_time_end > ?', Time.current) }
  scope :passed_events, -> { where('scheduled_time_end < ?', Time.current) }
  scope :most_recent, -> { order(scheduled_time_start: :asc) }
  scope :latest_passed, -> { order(scheduled_time_start: :desc) }
  scope :not_expired, -> { where.not(call_status: 'expired') }
  scope :not_declined, -> { where.not(call_status: 'declined') }
  scope :not_cancelled, -> { where.not(call_status: 'cancelled') }
  scope :pending_for_transfer, lambda {
    where(call_status: %w[finished denied_complaint])
  }
  # TODO- update/remove states for refunds
  scope :pending_for_completion, lambda {
    where(call_status: %w[requires_confirmation requires_reschedule_confirmation scheduled expired declined failed incompleted requires_time_change_confirmation])
  }

  scope :not_rejected, -> { where.not(call_status: :declined) }
  ## Callbacks
  before_validation :set_scheduled_call_duration, :set_scheduled_time_end, :set_call_time,
                    :set_rate, on: :create
  after_create :update_rate

  delegate :was_helpful, :rating, :feedback, :ask_for_feedback?, :reviewed_at, to: :expert_interaction

  ## Methods and helpers
  def twilio_call_type
    return 'group' if call_type == '1-5'

    'peer-to-peer'
  end

  def extra_users?
    guests_count > MAX_GUESTS_NUMBER
  end

  def extra_user_rate
    return 0 unless extra_users?

    ((guests_count - MAX_GUESTS_NUMBER) * expert.extra_user_rate) * (call_time / 60)
  end

  # total time multiplied by rate
  def total_payment
    @total_payment ||= rate * Stripes::Payments::BaseCreatorHandler::USD_CURRENCY_FACTOR
  end

  # amount payed to the expert discount the minnects fee
  def expert_payment
    (total_payment -
      (total_payment * expert.platform_fees))
  end

  # TODO: in feature update - improve query
  def available_to_scheduled?
    date_range = 1.minute.ago(scheduled_time_start)..1.minute.from_now(scheduled_time_end)
    calls_in_time_start_range = expert.expert_calls.scheduled
                                      .where(scheduled_time_start: date_range)
    calls_in_time_end_range = expert.expert_calls.scheduled
                                    .where(scheduled_time_end: date_range)
    scheduled_calls = calls_in_time_start_range.or(calls_in_time_end_range)
    return false if scheduled_calls.any?

    true
  end

  def cancellable?(user)
    if user.is_a?(Expert)
      return true if CANCELLATION_ALLOWED_FROM_STATUS.include?(call_status)
    else
      return true if Time.zone.now <= 1.minute.ago(scheduled_time_start) && CANCELLATION_ALLOWED_FROM_STATUS.include?(call_status)
    end

    false
  end

  def pending_for_completion?
    %w[requires_confirmation requires_reschedule_confirmation scheduled expired declined failed incompleted requires_reschedule_confirmation requires_time_change_confirmation].include?(call_status)
  end

  def cancelled?
    call_status == 'cancelled'
  end

  def rescheduled?
    rescheduling_requests.accepted.present?
  end

  def time_changed?
    time_change_requests.accepted.present?
  end

  def rescheduling_pending?
    rescheduling_requests.pending.present?
  end

  def time_change_request_pending?
    time_change_requests.pending.present?
  end

  def reschedulable?
    return false if time_change_requests.pending.present?

    return true if RESCHEDULING_ALLOWED_FROM_STATUS.include?(call_status) && Time.zone.now <= 24.hours.ago(scheduled_time_start) && !rescheduling_pending?

    false
  end

  def time_change_allowed?
    return false if time_change_requests.pending.present?

    return false if rescheduling_pending?

    return true if TIME_CHANGED_ALLOWED_FROM_STATUS.include?(call_status) && Time.zone.now <= 24.hours.ago(scheduled_time_start)

    false
  end

  def sub_text
    if cancelled?
      return I18n.t("api.expert_call.cancellation.subtext_without_comment", actor_name: cancelled_by.first_name) if !cancellation_reason.present?

      return I18n.t("api.expert_call.cancellation.subtext_with_comment", actor_name: cancelled_by.first_name, cancellation_reason: cancellation_reason) if cancellation_reason.present?
    end

    if rescheduling_pending?
      actor = rescheduling_request.rescheduled_by
      return I18n.t("api.expert_call.rescheduling.subtext_without_comment", actor_name: actor.first_name, call_duration: scheduled_call_duration, new_rescheduled_date_time: new_requested_start_time) if !rescheduling_request.rescheduling_reason.present?

      return I18n.t("api.expert_call.rescheduling.subtext_with_comment", actor_name: actor.first_name, call_duration: scheduled_call_duration, new_rescheduled_date_time: new_requested_start_time, rescheduling_reason: rescheduling_request.rescheduling_reason) if rescheduling_request.rescheduling_reason.present?
    end
  end

  def rescheduling_request
    return rescheduling_requests.pending.last if rescheduling_pending?

    return rescheduling_requests.accepted.last if rescheduled?

    nil
  end

  def time_change_request
    return time_change_requests.pending.last if time_change_request_pending?

    return time_change_requests.accepted.last if time_changed?

    return time_change_requests.declined.last if time_change_requests.declined.present?

    nil
  end

  def refundable_amount(individual = nil)
    current_time = Time.zone.now
    if individual.present?
      return 0 if current_time >= scheduled_time_start

      time_left = (Time.parse(scheduled_time_start.to_s) - Time.parse(current_time.to_s)) / 3600

      if time_left >= 24
        rate
      elsif time_left < 24 && time_left >= 12
        (rate.to_f / 2).round(2)
      else
        0
      end
    else
      return 0 if current_time >= scheduled_time_start
      rate
    end
  end

  def refund_description
    current_time = Time.zone.now
    time_left = (Time.parse(scheduled_time_start.to_s) - Time.parse(current_time.to_s)) / 3600
    if time_left >= 24
      I18n.t('api.expert_call.cancellation.full_refund_description')
    elsif time_left < 24 && time_left >= 12
      I18n.t('api.expert_call.cancellation.partial_refund_description')
    else
      I18n.t('api.expert_call.cancellation.no_refund_description')
    end
  end

  def cancellation_description
    current_time = Time.zone.now
    time_left = (Time.parse(scheduled_time_start.to_s) - Time.parse(current_time.to_s)) / 3600
    if time_left >= 24
      I18n.t('api.expert_call.cancellation.before_24_hours_description')
    elsif time_left < 24 && time_left >= 12
      I18n.t('api.expert_call.cancellation.12_24_hours_description')
    else
      I18n.t('api.expert_call.cancellation.0_12_hours_description')
    end
  end

  def reschedule_call!(reschedule_datetime)
    self.scheduled_time_start = reschedule_datetime
    set_scheduled_time_end
    save!
  end

  def change_time!(change_datetime)
    self.scheduled_time_start = change_datetime
    set_scheduled_time_end
    save!
  end

  def send_ongoing_call_notifications
    Notifications::OngoingCallNotifier.new(self).execute
  end

  def time_addition_duration_in_seconds
    TimeAddition::DURATION
  end

  def time_left_to_accept
    # return time left for an expert to accept
    return 0 if scheduled?

    return 0 if Time.zone.now > (created_at + ExpertCall::DEFAULT_HOURS_TO_ACCEPT.hours)

    remaining_time = (created_at + ExpertCall::DEFAULT_HOURS_TO_ACCEPT.hours) > scheduled_time_start ? scheduled_time_start : (created_at + ExpertCall::DEFAULT_HOURS_TO_ACCEPT.hours)
    distance_of_time_in_words(Time.zone.now, (remaining_time), true, highest_measure_only: true)
  end

  def time_left_to_accept_rescheduling_request
    # return time left to accept the rescheduling_request
    return '' unless rescheduling_pending?

    return '' if Time.zone.now >= 24.hours.ago(scheduled_time_start)

    remaining_time = new_requested_start_time > scheduled_time_start ? scheduled_time_start : new_requested_start_time
    distance_of_time_in_words(Time.zone.now, 24.hours.ago(remaining_time), true, highest_measure_only: true)
  end

  def time_left_in_start
    return '' unless scheduled?

    return '' if Time.zone.now > (scheduled_time_start)

    distance_of_time_in_words(Time.zone.now, scheduled_time_start, true, highest_measure_only: 2)
  end

  def time_left_to_accept_time_change_request
    # return time left to accept the rescheduling_request
    return '' unless time_change_request_pending?

    return '' if Time.zone.now >= 24.hours.ago(scheduled_time_start)

    remaining_time = new_requested_start_time > scheduled_time_start ? scheduled_time_start : new_requested_start_time
    distance_of_time_in_words(Time.zone.now, 24.hours.ago(remaining_time), true, highest_measure_only: true)
  end

  def call_status_label
    if %w[requires_confirmation requires_reschedule_confirmation requires_time_change_confirmation].include? call_status
      'Pending'
    elsif call_status == 'declined'
      'Declined'
    elsif %w[scheduled ongoing].include? call_status
      'Confirmed'
    elsif call_status == 'cancelled'
      'Cancelled'
    elsif ExpertCall::COMPLETED_STATUS.include? call_status
      'Completed'
    elsif call_status == 'expired'
      'Expired'
    elsif %w[incompleted unrefunded_for_incompleted_event].include? call_status
      'Incompleted'
    end
  end

  def new_requested_start_time
    time = rescheduling_requests.pending.last&.new_requested_start_time
    time = time_change_requests.pending.last&.new_suggested_start_time unless time.present?
    time = rescheduling_requests.accepted.last&.new_requested_start_time unless time.present?
    time = rescheduling_requests.declined.last&.new_requested_start_time unless time.present?
    time
  end

  private

  def active_users
    return if expert.nil? || expert.active?

    errors.add[:base] = 'The Expert User is inactive at the moment'
  end

  def update_rate
    set_rate
    save if rate_changed?
  end

  def get_scheduled_date_range # rubocop:todo Naming/AccessorMethodName
    scheduled_time_start..scheduled_time_end
  end

  def set_rate
    return unless expert

    self.rate = scheduled_call_duration *
      ExpertCalls::MinuteCostCalculation.new(self).call
  end

  # call_time in seconds
  def set_call_time
    return unless scheduled_call_duration

    self.call_time = scheduled_call_duration * 60
  end

  def guest_amount_match_call_type
    if call_type == CALL_TYPE_ONE_TO_ONE && guest_in_calls.size.positive? ||
      call_type == CALL_TYPE_ONE_TO_FIVE && guest_in_calls.size.zero?
      errors.add(:call_type, 'Does not match with the amount of guests')
    end
  end

  def set_scheduled_time_end
    return unless scheduled_time_start && scheduled_call_duration

    self.scheduled_time_end = scheduled_call_duration.minutes.from_now(
      scheduled_time_start
    )
  end

  # scheduled_call_duration in minutes
  def set_scheduled_call_duration
    return if scheduled_call_duration != 20

    self.scheduled_call_duration = DEFAULT_CALL_DURATION
  end

  def execute_refund(refund_amount)
    refund = Stripes::Refunds::RefundExpertCallHandler.call(self, refund_amount)
    time_additions_refunds = refund[:time_additions_refunds]
    time_additions_refunds.each do |time_addition_refund|
      ta = TimeAddition.find(time_addition_refund.metadata.interaction_id)
      if time_addition_refund.status == 'succeeded'
        ta.set_refund!
        Transactions::Create.call(ta, time_addition_refund, true)
        Refund.create(
          refundable: ta,
          payment_intent_id_ext: time_addition_refund.payment_intent,
          refund_id_ext: time_addition_refund.id,
          status: time_addition_refund.status,
          amount: time_addition_refund.amount,
          refund_metadata: time_addition_refund.metadata
        )
      else
        Alert.create(
          alertable: ta,
          message: time_addition_refund.try(:api_error),
          alert_type: :refund
        )
      end
    end
    if refund[:status] == 'succeeded'
      refund_object = OpenStruct.new(id: refund[:id], amount: refund[:amount])
      Transactions::Create.call(self, refund_object, true)
      Refund.create(
        refundable: self,
        payment_intent_id_ext: refund[:payment_intent],
        refund_id_ext: refund[:id],
        status: refund[:status],
        amount: refund[:amount],
        refund_metadata: refund[:metadata]
      )
      true
    else
      Alert.create(
        alertable: self,
        message: refund.try(:[], :api_error),
        alert_type: :refund
      )
      false
    end
  end

  def execute_transfer
    if ZERO_PERCENT_PAYOUTS_EXPERTS.include?(expert.id)
      Rails.logger.info "Skipping the transfer as the expert is in ZERO_PERCENT_PAYOUTS_EXPERTS"
      true
    else
      transfer = Stripes::Transfers::TransferInteractionAmountHandler.call(self)
      if transfer.object == 'transfer'
        time_additions.confirmed.each(&:transfer!)
        Transfer.create(
          transferable: self,
          transfer_id_ext: transfer.id,
          amount: transfer.amount,
          destination_account_id_ext: transfer.destination,
          balance_transaction_id_ext: transfer.balance_transaction,
          destination_payment_id_ext: transfer.destination_payment,
          reversed: transfer.reversed,
          transfer_metadata: transfer.metadata
        )
        true
      else
        Alert.create(
          alertable: self,
          message: transfer.try(:api_error),
          alert_type: :transfer
        )
        false
      end
    end
  end

  def execute_payment_capture
    Stripes::Payments::CapturePaymentHandler.call(self)
  end

  def cancel_payment_intent
    cancel_payment = Stripes::Payments::CancelPaymentIntentHandler.call(self)
    update(payment_status: 'payment_released')
  end

  def successful_transfer?
    execute_transfer
  end

  def successful_refund?
    payment_status == 'requires_capture' ? cancel_payment_intent : execute_refund(refund_amount)
  end

  def refund_amount
    if cancelled_by.present? && cancelled_by.is_a?(Individual)
      return 0 if cancelled_at >= scheduled_time_start

      time_left = (Time.parse(scheduled_time_start.to_s) - Time.parse(cancelled_at.to_s)) / 3600

      if time_left >= 24
        rate * Stripes::BaseService::USD_CURRENCY_FACTOR
      elsif time_left < 24 && time_left >= 12
        ((rate.to_f / 2).round(2) * Stripes::BaseService::USD_CURRENCY_FACTOR).to_i
      else
        0
      end
    else
      rate * Stripes::BaseService::USD_CURRENCY_FACTOR
    end
  end
end
