module PushNotification
  class SenderJob < ApplicationJob
    queue_as :notifications

    # rubocop:todo Metrics/ParameterLists
    # rubocop:todo Style/OptionalBooleanParameter
    def perform(device, message, silent = false, with_sound = true, payload_data = {},
                # rubocop:enable Style/OptionalBooleanParameter
                notification_type = nil, group_id = nil, collapse_id = nil,
                group_message = nil)
      notification_pusher = Mobile::OneSignal::NotificationPusher.new(device, message,
                                                                      payload_data: payload_data,
                                                                      notification_type: notification_type,
                                                                      silent: silent, group_id: group_id,
                                                                      collapse_id: collapse_id,
                                                                      group_message: group_message,
                                                                      with_sound: with_sound)
      notification_pusher.execute
      return if notification_pusher.success?

      PushNotification::SenderJob.perform_later(device, message, silent, with_sound,
                                                payload_data, notification_type,
                                                group_id, collapse_id, group_message)
    end
    # rubocop:enable Metrics/ParameterLists
  end
end
