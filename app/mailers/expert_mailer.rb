class ExpertMailer < ApplicationMailer
  def call_requested_mail(expert_call)
    @expert_call = expert_call
    @individual_user = @expert_call.individual.user
    @expert_user = @expert_call.expert.user
    @individual_expert_engagement = IndividualAndExpertEngagementService.new(@expert_call.individual, @expert_call.expert).completed_calls

    mail(
      to: @expert_user.email,
      subject: "New Call Request - #{ ActionController::Base.helpers.number_to_currency((@expert_call.expert_payment/100).to_i, locale: :en, precision: 0)} Opportunity!"
    )
  end

  def question_submitted_mail(question)
    @question = question
    @expert_user = @question.expert.user
    @individual_user = @question.individual.user
    @individual_expert_engagement = IndividualAndExpertEngagementService.new(@question.individual, @question.expert).answered_questions

    mail(
      to: @expert_user.email,
      subject: "New Question Request - #{ ActionController::Base.helpers.number_to_currency((@question.expert_payment/100).to_i, locale: :en, precision: 0)} Opportunity!"
    )
  end
end
