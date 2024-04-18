module Notifications
  module Individuals
    class ExpertCallNotifier
      include Notifications::CommonMethods

      def initialize(expert_call)
        @expert_call = expert_call
        @event = expert_call.class.to_s
        @event_id = expert_call.id
        @event_status = expert_call.call_status
      end

      def confirmed_call
        if individual_allow_notifications?
          silent_notification(individual_device, '', @event, @event_id, @event_status)
          message = "The expert #{expert_name} has accepted the #{call_type} video call"\
                    " \"#{@expert_call.title}\" scheduled to"\
                    " #{call_date(individual_timezone)}."
          PushNotification::SenderJob.perform_later(individual_device, message)
          IndividualMailer.call_confirmed_mail(@expert_call).deliver_later
        end
        send_confirmed_call_notification_to_guests
      end

      def rejected_call
        message = "The expert #{expert_name} has rejected the #{call_type} video call"\
                  " \"#{@expert_call.title}\"."
        send_notification(message)
      end

      def cancelled_call
        message = "The expert #{expert_name} has cancelled the #{call_type} video call"\
                  " \"#{@expert_call.title}\"."
        send_notification(message)
      end

      def rescheduled_call
        return unless individual_allow_notifications?

        silent_notification(individual_device, '', @event, @event_id, @event_status)
        message = " The expert #{expert_name} asks to rescheduled the #{call_type} video"\
                  " call \"#{@expert_call.title}\" to #{proposed_call_scheduled_time_start}."
        PushNotification::SenderJob.perform_later(individual_device, message)
      end

      def time_change_request
        return unless individual_allow_notifications?

        silent_notification(individual_device, '', @event, @event_id, @event_status)
        message = " The expert #{expert_name} asks to change the time for the #{call_type} video"\
                  " call \"#{@expert_call.title}\" to #{proposed_call_scheduled_time_start}."
        PushNotification::SenderJob.perform_later(individual_device, message)
      end

      def rescheduling_request_accepted
        return unless individual_allow_notifications?

        silent_notification(individual_device, '', @event, @event_id, @event_status)
        message = " The expert #{expert_name} has accepted your request to move your scheduled #{call_type} video"\
                  " call \"#{@expert_call.title}\" to #{call_date(individual_timezone)}."
        PushNotification::SenderJob.perform_later(individual_device, message)
      end

      def rescheduling_request_declined
        return unless individual_allow_notifications?

        silent_notification(individual_device, '', @event, @event_id, @event_status)
        message = " The expert #{expert_name} has declined your request to move your scheduled #{call_type} video"\
                  " call \"#{@expert_call.title}\" to #{call_date(individual_timezone)}."
        PushNotification::SenderJob.perform_later(individual_device, message)
      end

      def about_to_start
        message = "The #{call_type} video call \"#{@expert_call.title}\" with expert"\
                  " #{expert_name} is about to start in"\
                  " #{ExpertCall::MINUTES_ABOUT_TO_START_CALL_NOTIFICATION} minutes."
        send_notification_before_call_begin(message)
      end

      def new_call
        return unless individual_allow_notifications?

        IndividualMailer.call_submitted_mail(@expert_call).deliver_later
      end

      private

      def send_notification(message)
        @expert_call.guests.each do |guest|
          next unless guest.allow_notifications

          silent_notification(guest.user.device, '', @event, @event_id, @event_status)
          PushNotification::SenderJob.perform_later(guest.user.device, message)
        end
        return unless individual_allow_notifications?

        silent_notification(individual_device, '', @event, @event_id, @event_status)
        PushNotification::SenderJob.perform_later(individual_device, message)
      end

      def send_notification_before_call_begin(message)
        @expert_call.guests.each do |guest|
          next unless guest.allow_notifications

          PushNotification::SenderJob.set(
            wait_until: time_before_call_begin
          ).perform_later(guest.user.device, message)
        end
        return unless individual_allow_notifications?

        PushNotification::SenderJob.set(
          wait_until: time_before_call_begin
        ).perform_later(individual_device, message)
      end

      def send_confirmed_call_notification_to_guests
        @expert_call.guests.each do |guest|
          next unless guest.allow_notifications

          silent_notification(guest.user.device, '', @event, @event_id, @event_status)
          guest_timezone = guest.device&.timezone || Device::DEFAULT_TIMEZONE
          message = "The expert #{expert_name} has accepted the #{call_type} video call"\
                    " \"#{@expert_call.title}\" scheduled to"\
                    " #{call_date(guest_timezone)}."

          PushNotification::SenderJob.perform_later(guest.user.device, message)
        end
      end

      def individual_timezone
        @individual_timezone ||= @expert_call.individual.device&.timezone ||
                                 Device::DEFAULT_TIMEZONE
      end

      def call_date(user_timezone)
        @expert_call.scheduled_time_start
                    .in_time_zone(user_timezone)
                    .strftime('%B %d, %Y at %H:%M')
      end

      def proposed_call_scheduled_time_start
        Time.parse(@expert_call.new_requested_start_time.to_s).in_time_zone(individual_timezone).strftime("%B %d, %Y at %-I:%M %p")
      end

      def new_requested_change_time
        Time.parse(@expert_call.new_requested_start_time.to_s).in_time_zone(individual_timezone).strftime("%B %d, %Y at %-I:%M %p")
      end
    end
  end
end
