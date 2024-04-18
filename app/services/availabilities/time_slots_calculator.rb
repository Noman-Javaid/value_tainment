# related to Expert's availiabilities
module Availabilities
  # returns the time slot avaialable of a range in time related to the expert's Availabilities
  class TimeSlotsCalculator
    DEFAULT_TIME_ZONE = 'UTC'.freeze

    attr_reader :availability, :time_initial, :time_end, :individual,
                :individual_timezone, :expert_timezone, :call_duration

    # individual param could also be an expert used for rescheduled expert_call
    def initialize(availability, individual, time_initial, time_end,
                   call_duration = ExpertCall::DEFAULT_CALL_DURATION)
      @availability = availability
      @individual = individual
      @call_duration = if call_duration.nil?
                         ExpertCall::DEFAULT_CALL_DURATION.minutes
                       else
                         call_duration.minutes
                       end
      set_time_zones

      set_time_ranges(time_initial, time_end)
    end

    # returns a structure of days and its time slots available
    # @example
    # {
    #   date_initial: "2021-08-09",
    #   date_end: "2021-08-15",
    #   days: [
    #     {
    #       day: "2021-08-09",
    #       available_time: [
    #         { time_start: "09:00:00+00:00", time_end: "09:20:00+00:00" }
    #         , ...
    #       ]
    #     }, ...
    #   ]
    # }
    def execute
      {
        date_initial: time_initial.to_date.to_s,
        date_end: time_end.to_date.to_s,
        call_duration: (call_duration / 60).to_i,
        days: days_availabilities
      }
    end

    private
    # @example
    # [
    #   {
    #     day: "2021-08-09",
    #     available_time: [
    #       { time_start: "09:00:00+00:00", time_end: "09:20:00+00:00" },
    #       { time_start": "10:20:00+00:00", time_end: "10:40:00+00:00" }
    #     ]
    #   }, ...
    # ]
    def days_availabilities
      availabilities = []
      return availabilities unless availability

      time_interation = time_initial
      loop do
        availabilities << day_availabilities(time_interation)
        break unless (time_interation += 1.day).to_date <= time_end.to_date
      end

      availabilities
    end

    # @example
    #   {
    #     day: "2021-08-09",
    #     available_time: [
    #       { time_start: "09:00:00+00:00", time_end: "09:20:00+00:00" },
    #       { time_start": "10:20:00+00:00", time_end: "10:40:00+00:00" }
    #     ]
    #   }
    # rubocop:todo Naming/VariableName
    def day_availabilities(dateTime) # rubocop:todo Naming/MethodParameterName
      # rubocop:enable Naming/VariableName
      date_hash = { year: dateTime.year, month: dateTime.month, day: dateTime.day } # rubocop:todo Naming/VariableName
      day_time_slots = availabilities_weekly_time_slots[dateTime.wday] || [] # rubocop:todo Naming/VariableName

      {
        day: dateTime.to_date.to_s, # rubocop:todo Naming/VariableName
        available_time: day_time_slots.map do |day_time_slot|
                          map_available_time_blocks(
                            day_time_slot[:time_start].change(date_hash),
                            day_time_slot[:time_end].change(date_hash)
                          )
                        end.flatten
      }
    end

    def map_available_time_blocks(time_start, time_end)
      if time_start.to_date == Time.current.in_time_zone(@individual_timezone).to_date
        return [] if time_end <= min_time_to_schedule_on_current_day

        time_start = min_time_to_schedule_on_current_day if (time_start..time_end).include?(min_time_to_schedule_on_current_day)
      end

      call_scheduled_times_in_day = date_grouped_call_scheduled_times[time_start.to_date]
      time_blocks = []

      while (time_start + call_duration) <= time_end
        time_end_block = time_start + call_duration
        if time_block_not_taken?(time_start, time_end_block, call_scheduled_times_in_day)
          time_blocks << {
            time_start: time_start.strftime('%T%:z'),
            time_end: time_end_block.strftime('%T%:z')
          }
        end

        time_start += call_duration
      end

      time_blocks
    end

    # Current time plus half of the call_duration to give the expert time
    # to accept the call
    def min_time_to_schedule_on_current_day
      @min_time_to_schedule_on_current_day ||=
        adjust_slot_time_on_current_day(
          Time.now.in_time_zone(individual_timezone) + (call_duration / 2)
        )
    end

    # adjust time slot to start on a sharp number 15, 30, 45, top of hour
    def adjust_slot_time_on_current_day(minimum_time)
      minutes_offset = minimum_time.min
      minute_adjust = 0
      case minutes_offset
      when 1...15 then minute_adjust = 15 - minutes_offset
      when 16...30 then minute_adjust = 30 - minutes_offset
      when 31...45 then minute_adjust = 45 - minutes_offset
      when 46...60 then minute_adjust = 60 - minutes_offset
      end
      minimum_time + minute_adjust.minutes
    end

    # check if there are calls already in the time range
    # since the range is inclusive time_end in calculated minus 1.second
    def time_block_not_taken?(time_start, time_end, call_scheduled_times_in_day)
      return true unless call_scheduled_times_in_day

      call_scheduled_times_in_day.none? do |call_scheduled_time|
        (time_start..(time_end - 1.second)).include?(call_scheduled_time)
      end
    end

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
    def availabilities_weekly_time_slots
      @availabilities_weekly_time_slots ||=
        Availabilities::WeeklyTimeSlotsCalculator.new(availability,
                                                      individual_timezone, expert_timezone, time_initial).execute
    end

    # @example
    # {
    #   Sat, 11 Sep 2021 => #date
    #     [Sat, 11 Sep 2021 03:50:00.000000000 UTC +00:00, #datetime
    #      Sat, 11 Sep 2021 03:30:00.000000000 UTC +00:00,
    #      ...],
    #   ...
    # }
    def date_grouped_call_scheduled_times
      @date_grouped_call_scheduled_times ||=
        @availability.expert.expert_calls.scheduled
                     .where(scheduled_time_start: time_initial..time_end)
                     .pluck(:scheduled_time_start).group_by(&:to_date)
    end

    # set timezones and verify that they are valid
    def set_time_zones
      @individual_timezone = individual.user.device&.timezone
      @individual_timezone = DEFAULT_TIME_ZONE if !@individual_timezone || ActiveSupport::TimeZone[@individual_timezone].blank?

      return unless availability

      @expert_timezone = availability.expert.user.device&.timezone
      @expert_timezone = DEFAULT_TIME_ZONE if !@expert_timezone || ActiveSupport::TimeZone[@expert_timezone].blank?
    end

    def set_time_ranges(time_initial, time_end)
      current_time = Time.now.in_time_zone(individual_timezone)
      @time_initial = if time_initial.present?
                        time_initial.in_time_zone(individual_timezone)
                      else
                        current_time
                      end
      @time_initial = current_time if @time_initial < current_time

      @time_end = if time_end.present?
                    time_end.in_time_zone(individual_timezone)
                  else
                    @time_initial.end_of_month
                  end
    end
  end
end
