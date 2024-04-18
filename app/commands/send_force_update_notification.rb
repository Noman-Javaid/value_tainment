# frozen_string_literal: true

class SendForceUpdateNotification
  prepend SimpleCommand

  attr_accessor :device, :user

  def initialize(device, user)
    @device = device
    @user = user
  end

  def call
    # send sms
    TwilioServices::SendForceUpdateBySms.call(user, device)
    # send email
    ForceUpdateMailer.send_to(user, device).deliver_later
    # send notification
    Notifications::GeneralEventNotifier.new(I18n.t('general_messages.force_update_notification_text'), [user]).execute
  rescue Exception => e
    errors.add :error_message, e.message
  end
end
