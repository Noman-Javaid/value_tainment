class Api::V1::UtilsController < Api::V1::ApiController
  skip_before_action :authenticate_user!
  skip_before_action :check_user_activity

  def submit_contact_form
    submission = Utils::SubmitContactForm.call(submission_params)

    if submission.success?
      render json: { success: true, message: I18n.t('api.contact_form.submission_successful') }
    else
      json_error_response(submission.errors[:error_message].join(','), :bad_request)
    end
  end


  private

  def submission_params
    params.require(:contact_form_submission).permit(:name, :email, :title, :message)
  end

end
