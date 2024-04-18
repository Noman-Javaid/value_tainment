class Api::V1::Individual::UsersController < Api::V1::Individual::IndividualsController
  include Api::V1::Concerns::ValidateTransactionHelper

  def update
    @user = current_user

    return json_error_response('Invalid Password') unless available_to_execute?

    @user.start_setting_profile
    ActiveRecord::Base.transaction do
      @user.update!(user_params)
      @user.mark_as_profile_set!
      @individual.update!(individual_params) if individual_params.present?
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

  def individual_params
    data = params.require(:user).permit(:username)
    data[:username] = data[:username].presence if data.present?
    data
  end
end
