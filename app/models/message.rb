# == Schema Information
#
# Table name: messages
#
#  id              :uuid             not null, primary key
#  answer_type     :string           default("text")
#  content_type    :string
#  sender_type     :string           not null
#  status          :string           default("sent")
#  text            :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  attachment_id   :bigint
#  private_chat_id :uuid             not null
#  sender_id       :uuid             not null
#
# Indexes
#
#  index_messages_on_attachment_id    (attachment_id)
#  index_messages_on_private_chat_id  (private_chat_id)
#  index_messages_on_sender           (sender_type,sender_id)
#
# Foreign Keys
#
#  fk_rails_...  (attachment_id => attachments.id)
#  fk_rails_...  (private_chat_id => private_chats.id)
#
class Message < ApplicationRecord

  ## Constants
  EXPIRATION_DAYS = 7
  DEFAULT_HOURS_TO_ANSWER = 168
  validates :text, presence: true, length: { maximum: 1000 }

  enum status: { pending: 'pending', complete: 'complete', expired: 'expired', resubmitted: 'resubmitted', deleted: 'deleted', sent: 'sent' }, _prefix: true
  enum answer_type: { text: 'text', video: 'video' }
  belongs_to :sender, polymorphic: true
  belongs_to :private_chat
  #  belongs_to :attachment, optional: true
  has_one :attachment, dependent: :destroy
  has_many :transfers, as: :transferable, dependent: :destroy
  has_many :payments, as: :payable, dependent: :destroy
  has_many :transfers, as: :transferable, dependent: :destroy

  has_many :message_reads, dependent: :destroy

  delegate :expert, :individual, :expert_interaction, :expiration_date, to: :private_chat

  after_create :update_private_chat
  after_update :execute_transfer_if_complete

  default_scope { order(created_at: :asc) }

  def rate
    return expert.quick_question_text_rate if answer_type == 'text'

    expert.quick_question_video_rate
  end

  def total_payment
    @total_payment ||= rate * Stripes::Payments::BaseCreatorHandler::USD_CURRENCY_FACTOR
  end

  # amount payed to the expert discount the minnects fee
  def expert_payment
    (total_payment -
      (total_payment * expert.platform_fees))
  end

  def time_left
    # return time left for an expert to answer
    return nil unless pending?

    return nil if Time.zone.now > (created_at + response_time.hours)

    distance_of_time_in_words(Time.zone.now, (created_at + response_time.hours), true, highest_measure_only: true)
  end

  def pending?
    status_sent?
  end

  def response_time
    DEFAULT_HOURS_TO_ANSWER
  end

  def sent_at(for_user: nil)
    return Time.parse(created_at.to_s).in_time_zone(for_user.timezone).strftime("%b %d, %I:%M %P") if for_user.present?

    created_at.strftime("%b %d, %I:%M %P")
  end

  def price(formatted: false)
    return nil if sender.is_a?(Expert)

    case answer_type
    when 'video'
      price = expert.quick_question_video_rate.to_i
    else
      price = expert.quick_question_text_rate.to_i
    end

    return ActionController::Base.helpers.number_to_currency((price), locale: :en, precision: 0) if formatted

    price
  end

  def read_by_user?(reader)
    return true if sender_id == reader.id # if message sender is the reader

    message_reads.exists?(reader_id: reader.id, reader_type: reader.class.name)
  end

  def expiration_status(for_user: nil)
    return nil unless status_sent?

    today = Date.today
    if for_user.present? && for_user.is_a?(Individual) && private_chat.status == 'pending'
      return "#{expert.first_name.titleize} has until #{Time.parse(expiration_date.to_s).in_time_zone(for_user.timezone).strftime("%b %d at %l:%M %P")} to answer"
    end

    if expiration_date == today && private_chat.status == 'expired'
      "Expired Today"
    elsif expiration_date < today && private_chat.status == 'expired'
      return "Expired on #{Time.parse(expiration_date.to_s).in_time_zone(for_user.timezone).strftime('%b %d at %l:%M %P')}" if for_user.present?

      "Expired on #{expiration_date.strftime('%b %d at %l:%M %P')}"
    elsif expiration_date == today && private_chat.status == 'pending'
      "Expires Today"
    elsif expiration_date == today + 1.day && private_chat.status == 'pending'
      "Expires Tomorrow"
    elsif private_chat.status == 'pending'
      return "Expires on #{Time.parse(expiration_date.to_s).in_time_zone(for_user.timezone).strftime('%b %d at %l:%M %P')}" if for_user.present?

      "Expires on #{expiration_date.strftime('%b %d at %l:%M %P')}"
    end
  end

  def payment
    return unless payments.present?

    payments.last
  end

  private

  def update_private_chat
    if sender_id == private_chat.individual_id
      private_chat.pending!
      private_chat.update!(expiration_date: Time.now + DEFAULT_HOURS_TO_ANSWER.hours)
    end
  end

  def execute_transfer
    # exit if already transfers
    return true if transfers.where(reversed: false).exists?

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

  def execute_transfer_if_complete
    if status_complete?
      execute_transfer
    end
  end

end
