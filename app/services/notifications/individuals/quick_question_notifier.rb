module Notifications
  module Individuals
    class QuickQuestionNotifier
      include Notifications::CommonMethods

      def initialize(quick_question)
        @quick_question = quick_question
        @event = quick_question.class.to_s
        @event_id = quick_question.id
        @event_status = quick_question.status
      end

      def answered_question
        return unless individual_allow_notifications?

        silent_notification(individual_device, '', @event, @event_id, @event_status)
        message = "The Quick Question made to #{expert_name} was answered."
        PushNotification::SenderJob.perform_later(individual_device, message)
        IndividualMailer.question_answered_mail(@quick_question).deliver_later
      end

      def expired_question
        return unless individual_allow_notifications?

        message = "The Quick Question made to #{expert_name} expired."
        PushNotification::SenderJob.perform_later(individual_device, message)
      end

      def conversation_expired
        return unless individual_allow_notifications?

        message = "Your conversation with #{expert_name} has expired."
        PushNotification::SenderJob.perform_later(individual_device, message)
      end

      def new_question
        return unless individual_allow_notifications?

        IndividualMailer.question_submitted_mail(@quick_question).deliver_later
      end
    end
  end
end
