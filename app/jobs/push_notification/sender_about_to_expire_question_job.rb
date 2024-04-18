module PushNotification
  class SenderAboutToExpireQuestionJob < ApplicationJob
    queue_as :notifications

    # rubocop:todo Metrics/ParameterLists
    # rubocop:todo Style/OptionalBooleanParameter
    def perform(quick_question, device, message, silent = false, with_sound = true,
                # rubocop:enable Style/OptionalBooleanParameter
                payload_data = {}, notification_type = nil, group_id = nil,
                collapse_id = nil, group_message = nil)

      return unless quick_question.pending? || quick_question.draft_answered?

      PushNotification::SenderJob.perform_later(device, message, silent, with_sound,
                                                payload_data, notification_type,
                                                group_id, collapse_id, group_message)
    end
    # rubocop:enable Metrics/ParameterLists
  end
end
