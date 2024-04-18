class IndividualProfileCreationMailer < ApplicationMailer
  def send_to(user)
    @user = user
    subject = 'Individual Profile Has been Created For Your Account'

    mail(to: user.email, subject: subject)
  end
end
