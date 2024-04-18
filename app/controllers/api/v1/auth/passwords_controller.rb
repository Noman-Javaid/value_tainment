class Api::V1::Auth::PasswordsController < Devise::PasswordsController
  before_action :find_resource, on: [:create]
  include Api::V1::Concerns::ApiResponses
  include Api::V1::Concerns::ExceptionHandler

  # FIXME: This shouldn't be necessary due to routing namespaces.
  # However it was needed in order to avoid a ActionController::UnknownFormat.
  respond_to :json
  after_action -> { request.session_options[:skip] = true }

  skip_before_action :verify_authenticity_token

  private

  def find_resource
    return head(400) if params[:user].blank?

    User.find_by!(email: params[:user][:email])
  end
end
