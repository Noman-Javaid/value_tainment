# == Schema Information
#
# Table name: private_chats
#
#  id                :uuid             not null, primary key
#  created_by        :uuid
#  description       :string
#  expiration_date   :datetime
#  name              :string
#  participant_count :integer          default(2), not null
#  short_description :string
#  status            :string           default("pending"), not null
#  users_list        :string           default([]), is an Array
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  expert_id         :uuid             not null
#  individual_id     :uuid             not null
#
# Indexes
#
#  index_private_chats_on_expert_id      (expert_id)
#  index_private_chats_on_individual_id  (individual_id)
#
# Foreign Keys
#
#  fk_rails_...  (expert_id => experts.id)
#  fk_rails_...  (individual_id => individuals.id)
#
class PrivateChat < ApplicationRecord

  include ExpertActiveStateValidation

  enum status: { pending: 'pending',
                 active: 'active',
                 inactive: 'inactive',
                 banned: 'banned',
                 expired: 'expired',
                 closed: 'closed',
                 answered: 'answered' }
  has_many :messages
  belongs_to :expert
  belongs_to :individual
  has_one :expert_interaction, dependent: :destroy, as: :interaction

  after_commit :create_expert_interactions, on: :create

  scope :for_individual, ->(individual_id) { where("? = ANY (users_list)", individual_id) }
  scope :for_expert, ->(expert_id) { where("? = ANY (users_list)", expert_id) }
  scope :completed_chats, -> { where.not(status: 'pending') }
  # Define a scope to get the list of pending chats
  default_scope { order(updated_at: :desc) }

  def self.find_for_users(user_ids)
    user_ids = user_ids.sort
    where("array_to_string(users_list, ',') = ?", user_ids.join(',')).first
  end

  def messages_sent_by_user(sender_id)
    messages.where(sender_id: sender_id)
  end

  def unread_message_count_for(user)
    unread_messages(user).count
  end

  def unread_messages(user)
    messages.where.not(sender_id: user.id).where.not(id: user.message_reads.pluck(:message_id))
  end

  def last_pending_message_from_individual
    messages.where(sender_id: individual_id, status: 'sent').order(created_at: :asc).last
  end

  def last_message_from_individual
    messages.where(sender_id: individual_id).order(created_at: :asc).last
  end

  def last_message_status
    last_message_from_individual.status
  end

  def last_message_expiration_time_left
    last_message_from_individual.time_left
  end

  def expire!
    self.expired!
    last_message_from_individual.status_expired! if last_message_from_individual.present? && last_message_from_individual.status_sent?
  end

  def create_expert_interactions
    expert_interaction || create_expert_interaction!(expert: expert)
  end

  def formatted_expiration_date
    expiration_date.strftime("%b %d at %l:%M %P") if pending?
  end

  def status_description(for_user:)
    today = Date.today
    yesterday = today - 1.day

    if status == 'answered'
      if updated_at.to_date == today
        "Answered Today"
      elsif updated_at.to_date == yesterday
        "Answered Yesterday"
      else
        "Answered #{Time.parse(updated_at.to_s).in_time_zone(for_user.timezone).strftime('%B %d')}"
      end
    elsif expiration_date == today && status == 'expired'
      "Expired Today"
    elsif expiration_date < today && status == 'expired'
      "Expired #{Time.parse(expiration_date.to_s).in_time_zone(for_user.timezone).strftime('%B %d')}"
    elsif expiration_date == today && status == 'pending'
      "Expires Today"
    elsif expiration_date == today + 1.day && status == 'pending'
      "Expires Tomorrow"
    elsif status == 'pending'
      "Expires #{Time.parse(expiration_date.to_s).in_time_zone(for_user.timezone).strftime('%B %d')}"
    end
  end

  def latest_answer_type
    last_message_from_individual.answer_type if last_message_from_individual.present?
  end

  def latest_message_price(formatted: false)
    case latest_answer_type
    when 'video'
      price = expert.quick_question_video_rate.to_i
    else
      price = expert.quick_question_text_rate.to_i
    end

    return ActionController::Base.helpers.number_to_currency((price), locale: :en, precision: 0) if formatted

    price
  end

  def rate
    latest_message_price
  end

  def unread_message_count_for_user(user)
    messages.count { |message| !message.read_by_user?(user) }
  end
  def has_new_message_for_user?(user)
    unread_message_count_for_user(user).to_i > 0
  end

end
