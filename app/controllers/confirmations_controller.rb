class ConfirmationsController < Devise::ConfirmationsController
  layout false

  def show
    super do |resource|
      resource.update!(confirmed_at: Time.current) if existing_user?
    end
  end

  private
  def after_confirmation_path_for(_resource_name, resource)
    resource.update!(account_verified: true)
    success_confirmation_path
  end

  def existing_user?
    return true if params[:existing_user] == 'true'

    false
  end
end
