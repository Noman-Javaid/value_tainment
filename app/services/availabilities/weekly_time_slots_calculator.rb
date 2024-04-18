# related to Expert's availiabilities
module Availabilities
  # returns the ranges available of an Expert per day of week in the individual_timezone
  class WeeklyTimeSlotsCalculator
    DEFAULT_TIME_ZONE = 'UTC'.freeze
    attr_reader :availability,
                :individual_timezone, :expert_timezone

    def initialize(availability, individual_timezone, expert_timezone, day = nil)
      @availability = availability

      @individual_timezone = individual_timezone || DEFAULT_TIME_ZONE
      @expert_timezone = expert_timezone || DEFAULT_TIME_ZONE
      @day = day || Date.today
    end

    # Returns the ranges available of an Expert per day of week in the individual_timezone
    # If a range in the expert_timezone is broken into 2 days, returns the objects ranges
    # separated in their respective days
    def execute
      return {} unless availability

      days_with_available_ranges_in_individual_timezone
    end

    private

    # returns the available ranges in the individual's timezone group by day
    # The week days start by sunday = 0, and so on.
    # @example
    # {
    #   0 => [
    #     { time_start: "2016 07:00:00 AWST +08:00",
    #       time_end: "2016 12:00:00 AWST +08:00" }, #time_range
    #     ...
    #   ]
    #   1 => [...],
    # }
    def days_with_available_ranges_in_individual_timezone
      available_ranges_in_expert_timezone.map do |time_range_hash|
        set_individual_timezone_and_split(time_range_hash)
      end.flatten.group_by do |time_range| # rubocop:todo Style/MultilineBlockChain
        time_range[:time_start].wday
      end
    end

    # Returns a array of ranges based on { time_start: time, time_end: time } Hash.
    # Return only 1 element if the range does not move to another day when moving from the
    # expert's timezone to the invidual's one
    def set_individual_timezone_and_split(time_range_hash)
      # rubocop:todo Naming/AccessorMethodName
      time_range_hash[:time_start] = time_range_hash[:time_start]
                                       .in_time_zone(individual_timezone)
      time_range_hash[:time_end] = time_range_hash[:time_end]
                                     .in_time_zone(individual_timezone)
      return [time_range_hash] if time_range_hash[:time_start].to_date == time_range_hash[:time_end].to_date

      [
        {
          time_start: time_range_hash[:time_start],
          time_end: time_range_hash[:time_start].end_of_day
        },
        {
          time_start: time_range_hash[:time_end].beginning_of_day,
          time_end: time_range_hash[:time_end]
        }
      ]
    end

    # returns the ranges available for calls defined in the expert availability
    def available_ranges_in_expert_timezone
      available_week_in_expert_timezone.map do |available_day|
        time_start_end_for_daytype(available_day)
      end.compact
    end

    # get days selected by the expert as available
    def available_week_in_expert_timezone
      #today = Date.today # rubocop:todo Rails/Date

      @day.beginning_of_week.to_date.upto(@day.end_of_week.to_date).select do |date|
        availability.available_days.include?(date.strftime('%A').downcase)
      end
    end

    # sets a datetime with the experts timezone
    def datetime_in_expert_timezone(date, time)
      Time.zone.parse(Time.parse("#{date} #{time}").in_time_zone(expert_timezone).strftime('%R'))
      "#{date.strftime('%F')} #{time.strftime('%T')}".in_time_zone(expert_timezone)
    end

    # Return an object with the time ranges related to a day of the week
    # If for some reason the times are not set return nil
    def time_start_end_for_daytype(available_day)
      if available_day.on_weekday?
        unless availability.time_start_weekday_without_offset &&
          availability.time_end_weekday_without_offset
          return nil
        end

        time_start = datetime_in_expert_timezone(available_day,
                                                 availability.time_start_weekday_without_offset)
        time_end = datetime_in_expert_timezone(available_day,
                                               availability.time_end_weekday_without_offset)
      else
        unless availability.time_start_weekend_without_offset &&
          availability.time_end_weekend_without_offset
          return nil
        end

        time_start = datetime_in_expert_timezone(available_day,
                                                 availability.time_start_weekend_without_offset)
        time_end = datetime_in_expert_timezone(available_day,
                                               availability.time_end_weekend_without_offset)
      end

      { time_start: time_start, time_end: time_end }
    end
  end
end
