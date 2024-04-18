module Notifications
  module Experts
    class ExpertCallNotifier
      include Notifications::CommonMethods

      def initialize(expert_call)
        @expert_call = expert_call
        @event = expert_call.class.to_s
        @event_id = expert_call.id
        @event_status = expert_call.call_status
      end

      def new_call
        return unless expert_allow_notifications?

        silent_notification(expert_device, '', @event, @event_id, @event_status)
        message = "#{individual_name} invited you to the #{call_type} video call"\
                  " \"#{@expert_call.title}\" on #{call_date}."
        PushNotification::SenderJob.perform_later(expert_device, message)
        ExpertMailer.call_requested_mail(@expert_call).deliver_later
      end

      def about_to_start
        return unless expert_allow_notifications?

        message = "The #{call_type} video call \"#{@expert_call.title}\" with"\
                  " #{individual_name} is about to start in"\
                  " #{ExpertCall::MINUTES_ABOUT_TO_START_CALL_NOTIFICATION} minutes."
        PushNotification::SenderJob.set(
          wait_until: time_before_call_begin
        ).perform_later(expert_device, message)
      end

      # rescheduled confirmed notification to guests and expert
      def confirmed_rescheduled_call
        message = "#{individual_name} has accepted the #{call_type} video call"\
                  " \"#{@expert_call.title}\" rescheduled to #{call_date}."
        send_notification_to_expert_and_guests(message)
      end

      # rescheduled rejected notification to guests and expert
      def rejected_rescheduled_call
        message = "#{individual_name} has rejected the #{call_type} video call"\
                  " \"#{@expert_call.title}\"."
        send_notification_to_expert_and_guests(message)
      end

      def rescheduled_call
        return unless expert_allow_notifications?

        silent_notification(expert_device, '', @event, @event_id, @event_status)
        message = "#{individual_name} asks to rescheduled the #{call_type} video"\
                  " call \"#{@expert_call.title}\" to #{proposed_call_scheduled_time_start}."
        PushNotification::SenderJob.perform_later(expert_device, message)
      end

      def rescheduling_request_accepted
        return unless expert_allow_notifications?

        silent_notification(expert_device, '', @event, @event_id, @event_status)
        message = " The #{individual_name} has accepted your request to move your scheduled #{call_type} video"\
                  " call \"#{@expert_call.title}\" to #{proposed_call_scheduled_time_start}."
        PushNotification::SenderJob.perform_later(expert_device, message)
      end

      def time_change_request_accepted
        return unless expert_allow_notifications?

        silent_notification(expert_device, '', @event, @event_id, @event_status)
        message = "#{individual_name} has accepted your request to move your scheduled #{call_type} video"\
                  " call \"#{@expert_call.title}\" to #{time_in_expert_time_zone(@expert_call.time_change_request.new_suggested_start_time)}."
        PushNotification::SenderJob.perform_later(expert_device, message)
      end

      def rescheduling_request_declined
        return unless expert_allow_notifications?

        silent_notification(expert_device, '', @event, @event_id, @event_status)
        message = " The #{individual_name} has declined your request to move your scheduled #{call_type} video"\
                  " call \"#{@expert_call.title}\" to #{proposed_call_scheduled_time_start}."
        PushNotification::SenderJob.perform_later(expert_device, message)
      end

      def time_change_request_declined
        return unless expert_allow_notifications?
        silent_notification(expert_device, '', @event, @event_id, @event_status)
        message = " The #{individual_name} has declined your request to move your scheduled #{call_type} video"\
                  " call \"#{@expert_call.title}\" to #{time_in_expert_time_zone(@expert_call.time_change_request.new_suggested_start_time)}."
        PushNotification::SenderJob.perform_later(expert_device, message)
      end

      def cancelled_call
        message = "The individual #{individual_name} has cancelled the #{call_type} video call"\
                  " \"#{@expert_call.title}\"."
        send_notification_to_expert_and_guests(message)
      end

      private

      def call_date
        @call_date ||= call_scheduled_time_start.strftime('%B %d, %Y at %H:%M')
      end

      def proposed_call_scheduled_time_start
        Time.parse(@expert_call.new_requested_start_time.to_s).in_time_zone(expert_timezone).strftime("%B %d, %Y at %-I:%M %p")
      end

      def time_in_expert_time_zone(datetime)
        Time.parse(datetime.to_s).in_time_zone(expert_timezone).strftime("%B %d, %Y at %-I:%M %p")
      end

      def call_scheduled_time_start
        @call_scheduled_time_start = @expert_call.scheduled_time_start
                                                 .in_time_zone(expert_timezone)
      end

      def expert_timezone
        @expert_timezone ||= @expert_call.expert.device&.timezone ||
                             Device::DEFAULT_TIMEZONE
      end

      def send_notification_to_expert_and_guests(message)
        if expert_allow_notifications?
          silent_notification(expert_device, '', @event, @event_id, @event_status)
          PushNotification::SenderJob.perform_later(expert_device, message)
        end
        @expert_call.guests.each do |guest|
          next unless guest.allow_notifications

          silent_notification(expert_device, '', @event, @event_id, @event_status)
          PushNotification::SenderJob.perform_later(guest.user.device, message)
        end
      end
    end
  end
end
