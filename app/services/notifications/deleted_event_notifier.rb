module Notifications
  class DeletedEventNotifier
    def initialize(message, users)
      @users = users
      @message = message
    end

    def execute
      return if @users.empty? || @message.blank?

      @users.each do |user|
        next unless user.allow_notifications?

        PushNotification::SenderJob.perform_later(user.device, @message)
      end
    end
  end
end
