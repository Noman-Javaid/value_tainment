class Api::V1::Web::ExpertsController < Api::V1::ApiController
  skip_before_action :authenticate_user!
  skip_before_action :check_user_activity

  before_action :set_expert, only: %i[show reviews]

  def index
    @experts = ExpertSearchService.new(params)
                                  .execute
    render 'api/v1/individual/experts/search'
  end

  def show
    render 'api/v1/individual/experts/show'
  end

  def reviews
    @reviews = @expert.reviews.order(created_at: :desc).page(params[:page]).per(params[:per_page])
    render '/api/v1/reviews/reviews'
  end

  def rates
    render 'api/v1/expert/rates/index'
  end

  def featured
    @featured_experts = Expert.ready_for_interactions
                              .verified
                              .where(featured: true)
                              .order(interactions_count: :desc)
                              .page(params[:page])
                              .per(params[:per_page])
                              .includes(user: { picture_attachment: :blob })

    render 'api/v1/individual/experts/featured'
  end

  private

  def set_expert
    @expert = Expert.includes(:categories, user: :picture_attachment).find_by(id: params[:id])
    @expert = Expert.includes(:categories, user: :picture_attachment).find_by(slug: params[:id]) if @expert.blank?

    if @expert.blank?
      json_error_response('Unable to find the expert', :not_found) if @expert.blank?
    end

    json_error_response('Expert is not active', :not_found) if @expert.present? && !@expert.active
  end
end
