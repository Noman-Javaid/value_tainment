class Api::V1::Expert::ReviewsController < Api::V1::Expert::ExpertsController

  def index
    @reviews = @expert.reviews.page(params[:page]).per(params[:per_page])
    render '/api/v1/reviews/reviews'
  end
end
