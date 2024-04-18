class ExpertMailerPreview < ActionMailer::Preview
  def call_requested_mail
    ExpertMailer.call_requested_mail(ExpertCall.all.sample)
  end

  def question_submitted_mail
    ExpertMailer.question_submitted_mail(QuickQuestion.all.sample)
  end
end
