module Notifications
  class UpcomingEventReminderNotifier
    include Notifications::CommonMethods

    INITIAL_MESSAGE = 'You have an scheduled call about'.freeze

    def initialize(expert_call)
      @expert_call = expert_call
    end

    def execute
      reminders = Reminder.active
      return if reminders.empty?

      build_devices_list
      reminders.each do |reminder|
        next unless reminder.valid_to_notify?(@expert_call.scheduled_time_start)

        reminder_date = reminder.timer.hours.ago(@expert_call.scheduled_time_start)
        time_left = time_left_for_event(reminder_date)
        message = "#{INITIAL_MESSAGE} #{@expert_call.title} in #{time_left}"
        @devices.each do |device|
          PushNotification::SenderJob.set(wait_until: reminder_date)
                                     .perform_later(device, message)
        end
      end
    end

    private

    def time_left_for_event(reminder_date)
      time_diff = Time.diff(@expert_call.scheduled_time_start, reminder_date, '%H %N')
      return time_diff[:diff].split('hours ').last if time_diff[:hour].zero?

      time_diff[:diff]
    end
  end
end
