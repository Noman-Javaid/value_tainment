class CallTimeChangeRequestMailer < ApplicationMailer

  def send_to_individual(expert_call)
    @individual_user = expert_call.individual.user
    @expert_user = expert_call.expert.user
    @individual_email = @individual_user.email
    @current_call_date_time = Time.parse(expert_call.scheduled_time_start.to_s).in_time_zone(@individual_user.timezone).strftime("%B %d, %Y at %-I:%M %p")
    @proposed_call_date_time = Time.parse(expert_call.new_requested_start_time.to_s).in_time_zone(@individual_user.timezone).strftime("%B %d, %Y at %-I:%M %p")
    subject = "#{@expert_user.name} has asked to move your call time"
    mail(to: @individual_email, subject: subject)
  end

  def accepted_by_individual(expert_call)
    @individual_user = expert_call.individual.user
    @expert_user = expert_call.expert.user
    @individual_email = @individual_user.email
    @expert_email = @expert_user.email
    @current_call_date_time = Time.parse(expert_call.scheduled_time_start.to_s).in_time_zone(@expert_user.timezone).strftime("%B %d, %Y at %-I:%M %p")
    subject = "#{@individual_user.name} has accepted the time you suggested for your call 🎉"
    mail(to: @expert_email, subject: subject)
  end

  def declined_by_individual(expert_call)
    @individual_user = expert_call.individual.user
    @expert_user = expert_call.expert.user
    @individual_email = @individual_user.email
    @expert_email = @expert_user.email
    @new_call_date_time = Time.parse(expert_call.new_requested_start_time.to_s).in_time_zone(@expert_user.timezone).strftime("%B %d, %Y at %-I:%M %p")
    subject = "#{@individual_user.name} has declined the time you suggested for your call 🎉"
    mail(to: @expert_email, subject: subject)
  end
end
