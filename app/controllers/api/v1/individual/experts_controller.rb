class Api::V1::Individual::ExpertsController < Api::V1::Individual::IndividualsController
  before_action :set_expert, only: %i[show]
  before_action :set_private_chat, only: %i[show]
  def search
    Rails.cache.fetch('territory_flag_list', expires_in: 24.hours) do
      territory_hash = {}
      Territory.includes(flag_attachment: :blob).all.each do |territory|
        territory_hash[territory.alpha2_code] = territory.flag_url
      end
      territory_hash
    end

    @experts = ExpertSearchService.new(params)
                                  .execute
  end

  def show
  end

  def featured
    @featured_experts = Expert.ready_for_interactions
                              .verified
                              .where(featured: true)
                              .order(interactions_count: :desc)
                              .page(params[:page])
                              .per(params[:per_page])
                              .includes(user: { picture_attachment: :blob })
  end

  def top
    @top_experts = Expert.ready_for_interactions
                              .verified
                              .where('rating > ?', 4.7)
                              .order(rating: :desc)
                              .page(params[:page])
                              .per(params[:per_page])
                              .includes(user: { picture_attachment: :blob })
  end

  def great
    @great_experts = Expert.ready_for_interactions
                              .verified
                              .where('rating > ?', 4)
                              .order(rating: :desc)
                              .page(params[:page])
                              .per(params[:per_page])
                              .includes(user: { picture_attachment: :blob })
  end

  private

  def set_expert
    @expert = Expert.includes(:categories, user: :picture_attachment).find_by(id: params[:id])
    @expert = Expert.includes(:categories, user: :picture_attachment).find_by(slug: params[:id]) unless @expert.present?

    json_error_response('Unable to find the expert', :not_found) unless @expert.present?
    json_error_response('Expert is not active', :not_found) if @expert.present? && !@expert.active
  end

  def set_private_chat
    @private_chat = @individual.private_chats.find_by(expert_id: @expert.id) if @expert.present? &&  @individual.private_chats.present?
  end
end
