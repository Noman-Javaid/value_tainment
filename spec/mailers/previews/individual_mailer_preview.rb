class IndividualMailerPreview < ActionMailer::Preview
  def call_submitted_mail
    IndividualMailer.call_submitted_mail(ExpertCall.all.sample)
  end

  def call_confirmed_mail
    IndividualMailer.call_confirmed_mail(ExpertCall.all.sample)
  end

  def question_submitted_mail
    IndividualMailer.question_submitted_mail(QuickQuestion.all.sample)
  end

  def question_answered_mail
    IndividualMailer.question_answered_mail(QuickQuestion.all.sample)
  end
end
