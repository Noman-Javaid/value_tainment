# frozen_string_literal: true

class Utils::SubmitContactForm
  prepend SimpleCommand

  attr_accessor :form_data

  def initialize(form_data)
    @form_data = form_data
  end

  def call
    submission = ContactFormSubmission.new(form_data)

    if submission.save
      UtilsMailer.send_contact_form_submission(submission.reload.id).deliver_later
    else
      errors.add :error_message, submission.errors.full_messages.join(", ")
    end
  rescue StandardError => e
    errors.add :error_message, e.message
  end

  private

  def valid_rating?
    feedback_params[:rating].to_i >= 1 && feedback_params[:rating].to_i <= 5
  end

  def call_completed?
    ExpertCall::COMPLETED_STATUS.include?(interaction.call_status)
  end

end
