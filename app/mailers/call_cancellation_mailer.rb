class CallCancellationMailer < ApplicationMailer

  def send_to_expert(expert_call)
    @individual_user = expert_call.individual.user
    @expert_user = expert_call.expert.user
    @expert_email = @expert_user.email
    @call_date_time = Time.parse(expert_call.scheduled_time_start.to_s).in_time_zone(@expert_user.timezone).strftime("%B %d, %Y at %-I:%M %p")
    subject = 'Minnect! Your upcoming call has been cancelled.'
    mail(to: @expert_email, subject: subject)
  end

  def send_to_individual(expert_call)
    @individual_user = expert_call.individual.user
    @expert_user = expert_call.expert.user
    @individual_email = @individual_user.email
    @call_date_time = Time.parse(expert_call.scheduled_time_start.to_s).in_time_zone(@individual_user.timezone).strftime("%B %d, %Y at %-I:%M %p")
    subject = 'Minnect! Your upcoming call has been cancelled.'
    mail(to: @individual_email, subject: subject)
  end
end
