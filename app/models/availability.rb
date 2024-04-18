# == Schema Information
#
# Table name: availabilities
#
#  id                 :bigint           not null, primary key
#  friday             :boolean          default(FALSE), not null
#  monday             :boolean          default(FALSE), not null
#  saturday           :boolean          default(FALSE), not null
#  sunday             :boolean          default(FALSE), not null
#  thursday           :boolean          default(FALSE), not null
#  time_end_weekday   :string
#  time_end_weekend   :string
#  time_start_weekday :string
#  time_start_weekend :string
#  tuesday            :boolean          default(FALSE), not null
#  wednesday          :boolean          default(FALSE), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  expert_id          :uuid             not null
#
# Foreign Keys
#
#  fk_rails_...  (expert_id => experts.id)
#
class Availability < ApplicationRecord
  ## Associations
  belongs_to :expert

  ## Constants
  TIME_REGEX = /\A([0-1]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9](?:Z|[+-](?:2[0-3]|[01][0-9]):[0-5][0-9])\z/.freeze
  WEEKDAYS = %w[monday tuesday wednesday thursday friday].freeze
  WEEKEND = %w[saturday sunday].freeze

  ## Validations
  validates :time_start_weekday, presence: true, format: { with: TIME_REGEX },
                                 if: :weekdays?
  validates :time_end_weekday, presence: true, format: { with: TIME_REGEX },
                               if: :weekdays?
  validates :time_start_weekend, presence: true, format: { with: TIME_REGEX },
                                 if: :weekend?
  validates :time_end_weekend, presence: true, format: { with: TIME_REGEX },
                               if: :weekend?
  validate :weekday_time_range_validation, :weekend_time_range_validation,
           on: %i[create update]

  ## Methods and helpers
  # returns the array of all the days selected
  def available_days
    @available_days ||= [*get_weekdays_array, *get_weekend_array]
  end

  def get_weekdays_array # rubocop:todo Naming/AccessorMethodName
    return [] unless weekdays?

    WEEKDAYS.select { |day| try(day.to_sym) }
  end

  def get_weekend_array # rubocop:todo Naming/AccessorMethodName
    return [] unless weekend?

    WEEKEND.select { |day| try(day.to_sym) }
  end

  def weekdays?
    monday || tuesday || wednesday || thursday || friday
  end

  def weekend?
    saturday || sunday
  end

  def time_start_weekday_without_offset
    return nil unless time_start_weekday

    @time_start_weekday_without_offset ||= time_without_offset(time_start_weekday)
  end

  def time_end_weekday_without_offset
    return nil unless time_end_weekday

    @time_end_weekday_without_offset ||= time_without_offset(time_end_weekday)
  end

  def time_start_weekend_without_offset
    return nil unless time_start_weekend

    @time_start_weekend_without_offset ||= time_without_offset(time_start_weekend)
  end

  def time_end_weekend_without_offset
    return nil unless time_end_weekend

    @time_end_weekend_without_offset ||= time_without_offset(time_end_weekend)
  end

  private

  def weekday_time_range_validation
    return unless time_start_weekday && time_end_weekday

    errors.add(:time_end_weekday, 'can\'t be earlier or same as time_start') if time_start_weekday >= time_end_weekday
  end

  def weekend_time_range_validation
    return unless time_start_weekend && time_end_weekend

    errors.add(:time_end_weekend, 'can\'t be earlier or same as time_start') if time_start_weekend >= time_end_weekend
  end

  def weekday_time_presence_validation
    return unless weekdays?

    errors.add(:time_end_weekday, 'can\'t be empty') unless time_end_weekday
    errors.add(:time_start_weekday, 'can\'t be empty') unless time_start_weekday
  end

  def weekend_time_presence_validation
    return unless weekend?

    errors.add(:time_end_weekend, 'can\'t be empty') unless time_end_weekend
    errors.add(:time_start_weekend, 'can\'t be empty') unless time_start_weekend
  end

  def time_without_offset(time_string_with_offset)
    #splited_string = time_string_with_offset.split('+')
    #splited_string = time_string_with_offset.split('-') if splited_string.length < 2
    #Time.zone.parse(splited_string.first)
    Time.zone.parse(Time.parse(time_string_with_offset).strftime('%R'))
  end
end
