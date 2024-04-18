class Api::V1::Expert::RatesController < Api::V1::Expert::ExpertsController
  skip_before_action :authenticate_user!
  skip_before_action :check_user_activity
  skip_before_action :app_version_supported?
  skip_around_action :set_expert
  def index
    render 'api/v1/expert/rates/index'
  end
end
