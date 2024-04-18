class PasswordsController < Devise::PasswordsController
  after_action -> { request.session_options[:skip] = true }

  skip_before_action :verify_authenticity_token

  protected

  def after_resetting_password_path_for(_resource)
    welcome_back_path
  end
end
