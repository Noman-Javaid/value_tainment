class Api::V1::Auth::RegistrationsController < Devise::RegistrationsController
  include Api::V1::Concerns::ApiResponses
  include Api::V1::Concerns::ExceptionHandler

  skip_before_action :verify_authenticity_token
  after_action -> { request.session_options[:skip] = true }

  def create
    build_resource(sign_up_params.except(:requires_confirmation))
    unless requires_confirmation?
      resource.confirmed_at = DateTime.now
      resource.skip_confirmation!
    end
    resource.save!
    sign_up(resource_name, resource) unless requires_confirmation?
    @user = resource
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :first_name,
                                 :last_name, :role, :requires_confirmation)
  end

  def requires_confirmation?
    return true if sign_up_params[:requires_confirmation]&.to_s&.downcase == 'true'

    false
  end
end
