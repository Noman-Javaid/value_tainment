# == Schema Information
#
# Table name: time_additions
#
#  id             :uuid             not null, primary key
#  duration       :integer
#  payment_status :string
#  rate           :integer
#  status         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  expert_call_id :uuid             not null
#  payment_id     :string
#
# Foreign Keys
#
#  fk_rails_...  (expert_call_id => expert_calls.id)
#
class TimeAddition < ApplicationRecord
  ## Inheritance
  include PaymentScopes
  include AccountBalanceCalculation
  include TimeAdditions::StateMachine

  ## Constants
  # rubocop:todo Rails/EnvironmentVariableAccess
  DEFAULT_DURATION = (ENV['DEFAULT_TIME_ADDITION_DURATION'] || 20).to_i * 60
  # rubocop:enable Rails/EnvironmentVariableAccess
  DURATION = 15 * 60

  ## Associations
  belongs_to :expert_call
  has_one :transaction_history, class_name: 'Transaction', dependent: :nullify
  has_many :alerts, as: :alertable, dependent: :destroy
  has_many :refunds, as: :refundable, dependent: :destroy
  has_many :transfers, as: :transferable, dependent: :destroy

  ## Validations
  validates :rate, presence: true
  validates :duration, presence: true,
                       inclusion: { in: [DEFAULT_DURATION, DURATION] }

  ## Callbacks
  before_validation :set_duration, :set_rate, on: :create

  delegate :expert, to: :expert_call

  ## Methods and helpers
  def display_name
    expert_call.title
  end

  # total time multiplied by rate
  def total_payment
    @total_payment ||= rate * Stripes::Payments::BaseCreatorHandler::USD_CURRENCY_FACTOR
  end

  # amount payed to the expert discount the minnects fee
  def expert_payment
    (total_payment - (total_payment * expert.platform_fees))
  end

  private

  def set_rate
    return unless expert_call&.expert

    self.rate = (duration / 60).to_i * ExpertCalls::MinuteCostCalculation.new(expert_call).call
  end

  # Set time_addition duration in seconds
  def set_duration
    return unless expert_call

    self.duration ||= DEFAULT_DURATION
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

  def successful_refund?
    payment_status == 'requires_capture' ? cancel_payment_intent : execute_refund(rate * Stripes::BaseService::USD_CURRENCY_FACTOR)
  end

  def execute_payment_capture
    Stripes::Payments::CapturePaymentHandler.call(self)
  end

  def cancel_payment_intent
    Stripes::Payments::CancelPaymentIntentHandler.call(self)
    update!(payment_status: 'payment_released')
  end
end
