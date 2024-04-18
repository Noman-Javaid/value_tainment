# == Schema Information
#
# Table name: reminders
#
#  id         :bigint           not null, primary key
#  active     :boolean          default(TRUE), not null
#  detail     :string
#  timer      :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Reminder < ApplicationRecord
  ## Constants
  REMINDER_LIMIT_PER_EVENT = 2

  ## Validations
  validates :timer, presence: true, numericality: { greater_than_or_equal_to: 0.01 },
                    uniqueness: { scope: :active }

  ## Callbacks
  before_save :timer_adjust
  before_create :verify_active_reminder_limit

  ## Scopes
  scope :active, -> { where(active: true) }

  ## Methods and helpers
  def valid_to_notify?(event_date)
    timer.hours.ago(event_date) > Time.current
  end

  private

  # timer value in hours rounded with 2 decimals
  def timer_adjust
    self.timer = timer.round(2)
  end

  def verify_active_reminder_limit
    return unless Reminder.active.count >= REMINDER_LIMIT_PER_EVENT

    errors.add(:base, 'Active reminders per event is completed')
  end
end
