class Api::V1::UsersController < Api::V1::ApiController
  skip_before_action :app_version_supported?
  def show
    @user = current_user
  end
end
