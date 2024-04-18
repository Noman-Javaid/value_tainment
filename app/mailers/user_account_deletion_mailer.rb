class UserAccountDeletionMailer < ApplicationMailer
  def send_to(user_email, user_name)
    @user_email = user_email
    @user_name = user_name
    subject = 'User Account Deletion Completed'

    mail(to: @user_email, subject: subject)
  end
end
