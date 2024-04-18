class Api::V1::CategoriesController < Api::V1::ApiController
  skip_before_action :authenticate_user!
  skip_before_action :check_user_activity
  skip_before_action :app_version_supported?
  def index
    @categories = Category.active.order(name: :asc).all
  end

  def show
    @category = Category.active.find(params[:id])
  end
end
