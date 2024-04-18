module Notifications
  module Experts
    class PaymentNotifier
      include Notifications::CommonMethods

      def initialize(expert, amount)
        @expert = expert
        @amount = amount
      end

      def execute
        return unless @expert.allow_notifications

        message = "A transfer with the amount of $#{@amount} has been made to your"\
                  ' account.'
        PushNotification::SenderJob.perform_later(@expert.device, message)
      end
    end
  end
end
