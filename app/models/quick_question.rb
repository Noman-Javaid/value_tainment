# frozen_string_literal: true

# == Schema Information
#
# Table name: quick_questions
#
#  id                       :uuid             not null, primary key
#  answer                   :text
#  answer_date              :datetime
#  answer_type              :string           default("choose")
#  description              :text             not null
#  payment_status           :string
#  question                 :string           not null
#  rate                     :integer          default(0), not null
#  response_time            :integer
#  status                   :string           default("pending")
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  category_id              :integer
#  expert_id                :uuid             not null
#  individual_id            :uuid             not null
#  payment_id               :string
#  refund_id                :string
#  stripe_payment_method_id :string
#
# Indexes
#
#  index_quick_questions_on_category_id    (category_id)
#  index_quick_questions_on_expert_id      (expert_id)
#  index_quick_questions_on_individual_id  (individual_id)
#
# Foreign Keys
#
#  fk_rails_...  (expert_id => experts.id)
#  fk_rails_...  (individual_id => individuals.id)
#

class QuickQuestion < ApplicationRecord
  ## Inheritance
  include PaymentScopes
  include TransitionGuards
  include ActAsInteractions
  include AccountBalanceCalculation
  include ExpertActiveStateValidation
  include QuickQuestions::StateMachine
  include QuickQuestions::AnswerParser

  ## Constants
  EXPIRATION_DAYS = 5
  DEFAULT_HOURS_TO_ANSWER = 120
  MINUTES_ABOUT_TO_EXPIRE_NOTIFICATION = 5
  NOT_YET_EXPIRED_QUERY = '(response_time - (EXTRACT(EPOCH FROM (NOW() - created_at)))) >= 0'
  PAYMENT_STATUS_PENDING = 'requires_confirmation'
  PAYMENT_STATUS_CANCELED = 'canceled'
  PAYMENPAYMENT_STATUS_SUCCEEDEDT_STATUS_SUCCEEDED = 'succeeded'
  UNANSWERED_STATUS = %w[failed pending draft_answered expired]
  PENDING_EARNING_STATUS = %w(pending answered draft_answered filed_complaint approved_complaint denied_complaint untransferred unrefunded unrefunded_for_incompleted_event)
  ## Evaluators
  paginates_per 10

  ## Associations
  belongs_to :expert
  belongs_to :individual
  belongs_to :category, optional: true

  has_one :attachment, dependent: :destroy
  has_many :alerts, as: :alertable, dependent: :destroy
  has_many :refunds, as: :refundable, dependent: :destroy
  has_many :transfers, as: :transferable, dependent: :destroy

  delegate :name, :quick_question_rate, :url_picture, :status, :rating, :reviews_count, :total_ratings, :total_reviews, to: :expert, prefix: true
  delegate :name, :url_picture, to: :individual, prefix: true
  delegate :name, :id, to: :category, prefix: true, allow_nil: nil

  delegate :was_helpful, :rating, :feedback, :ask_for_feedback?, :reviewed_at, to: :expert_interaction

  ## Validations
  validates :expert, presence: true
  validates :individual, presence: true
  validates :question, presence: true, length: { maximum: 50 }
  validates :description, presence: true, length: { maximum: 2000 }
  validates :answer, length: { maximum: 5000 }, allow_blank: true
  validates :stripe_payment_method_id, presence: true
  validates :rate, presence: true
  validates :response_time, presence: true,
                            numericality: { only_integer: true, greater_than: 0 }
  validates :answer_type, inclusion: { in: %w[text video choose], message: 'is invalid' }

  ## Scopes
  scope :has_not_expired, -> { where(NOT_YET_EXPIRED_QUERY) }
  scope :answered_question_list, lambda {
    where.not(
      status: UNANSWERED_STATUS
    )
  }
  scope :most_recent, -> { order(created_at: :desc) }
  scope :pending_for_transfer, lambda {
    where(status: %w[answered denied_complaint])
  }
  # TODO- update/remove states for refunds
  scope :pending_for_completion, lambda {
    where(status: %w[pending draft_answered expired failed])
  }

  attr_accessor :answered_as_draft

  ## Callbacks
  before_validation :update_status_to_answered
  before_validation :set_rate, :set_response_time, on: :create
  before_validation :update_status_to_draft_answered, on: :update

  def self.ransackable_attributes(auth_object = nil)
    %w[status]
  end

  def category_name
    category.name if category
  end

  def category_id
    category.id if category
  end

  ## Methods and helpers
  def display_name
    question
  end

  # returns time in hours to answer a question
  def self.time_to_answer
    SettingVariable.first&.response_time_to_hours || DEFAULT_HOURS_TO_ANSWER
  end

  def time_left
    # return time left for an expert to answer
    return '0' if answered?

    return '0' if Time.zone.now > (created_at + response_time.hours)

    distance_of_time_in_words(Time.zone.now, (created_at + response_time.hours), true, highest_measure_only: true)
  end

  # total time mutiplied by rate
  def total_payment
    @total_payment ||= rate * Stripes::Payments::BaseCreatorHandler::USD_CURRENCY_FACTOR
  end

  # amount payed to the expert discount the minnects fee
  def expert_payment
    (total_payment -
     (total_payment * expert.platform_fees))
  end

  def allow_to_upload_attachment?
    return true if pending? || draft_answered?

    false
  end

  def attachment_url?
    return false unless attachment&.in_bucket?

    true
  end

  def parsed_answer
    # sample [https://apple.com](https://apple.com)
    parse_answer(answer) if answer.present?
  end

  def is_answered
    answered? || UNANSWERED_STATUS.exclude?(status)
  end

  private

  def set_response_time
    self.response_time = QuickQuestion.time_to_answer
  end

  def set_rate
    return unless expert

    if self.answer_type == 'video'
      self.rate = expert.quick_question_video_rate
    else
      self.rate = expert.quick_question_text_rate
    end
  end

  def update_status_to_answered
    return unless (pending? || draft_answered?) && answer && answer_date

    set_as_answered
    Notifications::Individuals::QuickQuestionNotifier.new(self).answered_question
  end

  def update_status_to_draft_answered
    set_as_draft_answered if pending? && answer && answered_as_draft
  end

  def execute_refund(amount)
    refund = Stripes::Refunds::RefundInteractionHandler.call(self, amount)
    if refund.status == 'succeeded'
      Transactions::Create.call(self, refund, true)
      Refund.create(
        refundable: self,
        payment_intent_id_ext: refund.payment_intent,
        refund_id_ext: refund.id,
        status: refund.status,
        amount: refund.amount,
        refund_metadata: refund.metadata
      )
      true
    else
      Alert.create(
        alertable: self,
        message: refund.try(:api_error),
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

  def successful_transfer?
    execute_transfer
  end

  def successful_refund?
    execute_refund(rate * Stripes::BaseService::USD_CURRENCY_FACTOR)
  end

end
