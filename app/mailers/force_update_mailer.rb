class ForceUpdateMailer < ApplicationMailer
  def send_to(user, device)
    @user_email = user.email
    @user_name = user.name
    @app_download_url = device.download_url
    subject = 'Minnect Update Required'

    mail(to: @user_email, subject: subject)
  end
end
