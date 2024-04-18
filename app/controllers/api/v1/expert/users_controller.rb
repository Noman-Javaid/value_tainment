class Api::V1::Expert::UsersController < Api::V1::Expert::ExpertsController
  include Api::V1::Concerns::ValidateTransactionHelper

  def update
    @user = current_user

    raise ActionController::ParameterMissing unless category_params&.any?

    return json_error_response('Invalid Password') unless available_to_execute?

    ActiveRecord::Base.transaction do
      @user.start_setting_profile
      @user.update!(user_params)
      @user.expert.update!(user_expert_params)
      @user.expert.category_ids = category_params
      @user.mark_as_profile_set!
    end
    render '/api/v1/users/show'
  end

  private

  def user_params
    sanitize_phone_number
    params.require(:user).permit(
      :first_name, :last_name, :date_of_birth, :gender, :zip_code,
      :phone_number, :phone, :country_code, :country, :city
    )
  end

  def sanitize_phone_number
    if params['user']['phone_number'].present?
      # remove the all non-digit characters
      params['user']['phone_number'] = params['user']['phone_number'].scan(/\d/).join
    end
  end

  def user_expert_params
    params.require(:user).permit(
      :biography, :website_url, :linkedin_url, :quick_question_rate,
      :one_to_one_video_call_rate, :one_to_five_video_call_rate,
      :extra_user_rate, :twitter_url, :instagram_url,
      :quick_question_text_rate, :quick_question_video_rate, :video_call_rate
    )
  end

  def category_params
    params.require(:categories)
  end
end
