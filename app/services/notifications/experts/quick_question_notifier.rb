module Notifications
  module Experts
    class QuickQuestionNotifier
      include Notifications::CommonMethods

      def initialize(quick_question)
        @quick_question = quick_question
        @event = quick_question.class.to_s
        @event_id = quick_question.id
        @event_status = quick_question.status
      end

      def new_question
        return unless expert_allow_notifications?

        silent_notification(expert_device, '', @event, @event_id, @event_status)
        message = "You have a new Quick Question from #{individual_name}."
        PushNotification::SenderJob.perform_later(expert_device, message)
        ExpertMailer::question_submitted_mail(@quick_question).deliver_later
      end

      def about_to_expire
        return unless expert_allow_notifications?

        message = "#{possessive_name(individual_name)} Quick Question is about to expire"\
                  " in #{QuickQuestion::MINUTES_ABOUT_TO_EXPIRE_NOTIFICATION} minutes."
        notification_date = ((@quick_question.response_time * 60) -
                             QuickQuestion::MINUTES_ABOUT_TO_EXPIRE_NOTIFICATION)
                            .minutes.from_now
        PushNotification::SenderAboutToExpireQuestionJob.set(
          wait_until: notification_date
        ).perform_later(@quick_question, expert_device, message)
      end
    end
  end
end
