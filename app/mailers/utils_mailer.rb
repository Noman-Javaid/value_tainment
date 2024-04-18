class UtilsMailer < ApplicationMailer
  FEEDBACK_EMAIL_ID = 'feedback@minnect.com'.freeze
  STAFF_EMAIL_IDS  = %w(wsukonik@valuetainment.com minnectapp@gmail.com)

  def send_contact_form_submission(submission_id)
    @form_submission = ContactFormSubmission.find(submission_id)
    subject = 'New web suggest expert submission'
    mail(to: FEEDBACK_EMAIL_ID, bcc: STAFF_EMAIL_IDS, subject: subject)
  end
end
