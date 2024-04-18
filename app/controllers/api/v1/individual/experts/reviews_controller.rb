class Api::V1::Individual::Experts::ReviewsController < Api::V1::Individual::ExpertsController
  before_action :set_expert

  def index
    @reviews = @expert.reviews.page(params[:page]).per(params[:per_page])
    render '/api/v1/reviews/reviews'
  end

  private

  def set_expert
    @expert = Expert.find(params[:expert_id])
  end
end
