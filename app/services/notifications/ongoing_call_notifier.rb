module Notifications
  class OngoingCallNotifier
    include Notifications::CommonMethods

    def initialize(expert_call)
      @expert_call = expert_call
      @event = expert_call.class.to_s
      @event_id = expert_call.id
      @event_status = expert_call.call_status
    end

    def execute
      devices = []
      devices.push(expert_device) if expert_allow_notifications?
      devices.push(individual_device) if individual_allow_notifications?

      @expert_call.guests.each do |guest|
        next unless guest.allow_notifications

        devices.push(guest.user.device)
      end
      devices.each do |device|
        silent_notification(device, '', @event, @event_id, @event_status)
      end
    end
  end
end
