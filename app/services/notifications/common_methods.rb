module Notifications
  module CommonMethods
    private

    def expert_name
      @expert_name ||= interaction.expert.name
    end

    def individual_name
      @individual_name ||= interaction.individual.name
    end

    def expert_device
      @expert_device ||= interaction.expert.device
    end

    def individual_device
      @individual_device ||= interaction.individual.device
    end

    def call_type
      @call_type ||= @expert_call.call_type.gsub('-', ':')
    end

    def possessive_name(name)
      name + (name[-1, 1] == 's' ? "'" : "'s")
    end

    def interaction
      @interaction = @quick_question || @expert_call || @message
    end

    def expert_allow_notifications?
      @expert_allow_notifications ||= interaction.expert.allow_notifications
    end

    def individual_allow_notifications?
      @individual_allow_notifications ||= interaction.individual.allow_notifications
    end

    def time_before_call_begin
      @time_before_call_begin ||= ExpertCall::MINUTES_ABOUT_TO_START_CALL_NOTIFICATION
                                  .minutes.ago(
                                    @expert_call.scheduled_time_start
                                  )
    end

    def silent_notification(device, message, event, event_id, event_status)
      PushNotification::SenderJob.perform_later(
        device, message, true, false,
        {
          event: event,
          event_id: event_id,
          event_status: event_status
        }
      )
    end

    def build_devices_list
      @devices = []
      @devices.push(expert_device) if expert_allow_notifications?
      @devices.push(individual_device) if individual_allow_notifications?

      @expert_call.guests.each do |guest|
        next unless guest.allow_notifications

        @devices.push(guest.user.device)
      end
    end
  end
end
