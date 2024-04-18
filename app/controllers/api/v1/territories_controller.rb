class Api::V1::TerritoriesController < Api::V1::ApiController
  skip_before_action :authenticate_user!
  skip_before_action :check_user_activity
  skip_before_action :app_version_supported?

  def index
    @territories = Territory.active.order('phone_code::integer')
  end

  def show
    @territory = Territory.find(params[:id])
  end
end
