class IndividualMailer < ApplicationMailer
  def call_submitted_mail(expert_call)
    @expert_call = expert_call
    @individual_user = @expert_call.individual.user
    @expert_user = @expert_call.expert.user

    mail(
      to: @individual_user.email,
      subject: "Booking Confirmation - Your Upcoming Call with #{@expert_user.first_name}"
    )
  end

  def call_confirmed_mail(expert_call)
    @expert_call = expert_call
    @individual_user = @expert_call.individual.user
    @expert_user = @expert_call.expert.user

    mail(
      to: @individual_user.email,
      subject: "Call Confirmed! - Your Upcoming Call with #{@expert_user.first_name}"
    )
  end

  def question_submitted_mail(question)
    @question = question
    @individual_user = @question.individual.user
    @expert_user = @question.expert.user

    mail(
      to: @individual_user.email,
      subject: "Submission Confirmation - Your Question for #{@expert_user.first_name}"
    )
  end

  def question_answered_mail(question)
    @individual_user = question.individual.user
    @expert_name = question.expert.user.first_name

    mail(
      to: @individual_user.email,
      subject: "Question Answered! - Check out #{@expert_name}'s answer"
    )
  end
end
