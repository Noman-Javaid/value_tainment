class CallReschedulingMailer < ApplicationMailer

  def send_to_expert(expert_call)
    @individual_user = expert_call.individual.user
    @expert_user = expert_call.expert.user
    @expert_email = @expert_user.email
    @current_call_date_time = Time.parse(expert_call.scheduled_time_start.to_s).in_time_zone(@expert_user.timezone).strftime("%B %d, %Y at %-I:%M %p")
    @proposed_call_date_time = Time.parse(expert_call.new_requested_start_time.to_s).in_time_zone(@expert_user.timezone).strftime("%B %d, %Y at %-I:%M %p")
    subject = 'Minnect! New rescheduling request.'
    mail(to: @expert_email, subject: subject)
  end

  def send_to_individual(expert_call)
    @individual_user = expert_call.individual.user
    @expert_user = expert_call.expert.user
    @individual_email = @individual_user.email
    @current_call_date_time = Time.parse(expert_call.scheduled_time_start.to_s).in_time_zone(@individual_user.timezone).strftime("%B %d, %Y at %-I:%M %p")
    @proposed_call_date_time = Time.parse(expert_call.new_requested_start_time.to_s).in_time_zone(@individual_user.timezone).strftime("%B %d, %Y at %-I:%M %p")
    subject = 'Minnect! New rescheduling request.'
    mail(to: @individual_email, subject: subject)
  end

  def accepted_by_expert(expert_call)
    @individual_user = expert_call.individual.user
    @expert_user = expert_call.expert.user
    @individual_email = @individual_user.email
    @current_call_date_time = Time.parse(expert_call.scheduled_time_start.to_s).in_time_zone(@individual_user.timezone).strftime("%B %d, %Y at %-I:%M %p")
    subject = 'Minnect! Call Rescheduling request accepted.'
    mail(to: @individual_email, subject: subject)
  end

  def accepted_by_individual(expert_call)
    @individual_user = expert_call.individual.user
    @expert_user = expert_call.expert.user
    @individual_email = @individual_user.email
    @expert_email = @expert_user.email
    @current_call_date_time = Time.parse(expert_call.scheduled_time_start.to_s).in_time_zone(@expert_user.timezone).strftime("%B %d, %Y at %-I:%M %p")
    subject = 'Minnect! Call Rescheduling request accepted.'
    mail(to: @expert_email, subject: subject)
  end

  def declined_by_expert(expert_call)
    @individual_user = expert_call.individual.user
    @expert_user = expert_call.expert.user
    @individual_email = @individual_user.email
    @new_call_date_time = Time.parse(expert_call.new_requested_start_time.to_s).in_time_zone(@individual_user.timezone).strftime("%B %d, %Y at %-I:%M %p")
    subject = 'Minnect! Call Rescheduling request declined.'
    mail(to: @individual_email, subject: subject)
  end

  def declined_by_individual(expert_call)
    @individual_user = expert_call.individual.user
    @expert_user = expert_call.expert.user
    @individual_email = @individual_user.email
    @expert_email = @expert_user.email
    @new_call_date_time = Time.parse(expert_call.new_requested_start_time.to_s).in_time_zone(@expert_user.timezone).strftime("%B %d, %Y at %-I:%M %p")
    subject = 'Minnect! Call Rescheduling request declined.'
    mail(to: @expert_email, subject: subject)
  end
end
