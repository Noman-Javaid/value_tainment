# TODO: most of this can be worked around using ransack
class ExpertSearchService
  def initialize(params)
    @params =
      if params.respond_to?(:permit!)
        params.permit!.to_h
      else
        params
      end
  end

  def execute
    experts = Expert.select("experts.*, users.first_name || ' ' || users.last_name collate \"C\" as name")
                    .ready_for_interactions
    experts = experts.search_by_name(name_param) if name_param
    experts = experts.where(categories_param) if categories_param
    experts = experts.where(*min_rate_param) if min_rate_param
    experts = experts.where(*max_rate_param) if max_rate_param
    experts = experts.where(*min_rating_param) if min_rating_param
    experts = experts.where(*max_rating_param) if max_rating_param
    experts = experts.reorder(order_param)
    experts = experts.page(page_param) if page_param
    experts = experts.per(per_page_param) if per_page_param
    experts.distinct.preload(:categories, user: { picture_attachment: :blob })
  end

  private

  def name_param
    return unless @params.key?(:name) &&
                  @params[:name].present?

    @params[:name]
  end

  def min_rate_param
    return unless @params.key?(:rates) &&
                  @params[:rates].key?(:field) &&
                  @params[:rates].key?(:minimum) &&
                  valid_rate_fields.include?(@params[:rates][:field])

    ["experts.#{@params[:rates][:field]} >= ?", @params[:rates][:minimum]]
  end

  def max_rate_param
    return unless @params.key?(:rates) &&
                  @params[:rates].key?(:field) &&
                  @params[:rates].key?(:maximum) &&
                  valid_rate_fields.include?(@params[:rates][:field])

    ["experts.#{@params[:rates][:field]} <= ?", @params[:rates][:maximum]]
  end

  def min_rating_param
    return unless @params.key?(:rating) &&
      @params[:rating].key?(:field) &&
      @params[:rating].key?(:minimum)

    ["experts.#{@params[:rating][:field]} >= ?", @params[:rating][:minimum]]
  end

  def max_rating_param
    return unless @params.key?(:rating) &&
      @params[:rating].key?(:field) &&
      @params[:rating].key?(:maximum)

    ["experts.#{@params[:rating][:field]} <= ?", @params[:rating][:maximum]]
  end

  def categories_param
    return unless @params.key?(:categories) &&
                  @params[:categories].instance_of?(Array) &&
                  @params[:categories].any?

    {
      categories: {
        id: @params[:categories]
      }
    }
  end

  def order_param
    if @params.key?(:order) &&
       @params[:order].instance_of?(Array) &&
       @params[:order].any?

      valid_order_params =
        @params[:order].filter { |o| order_fields.keys.include?(o.to_a.first.first.to_s) && %w[asc desc].include?(o.to_a.first.last) }
      return "#{order_fields['name']} asc" if valid_order_params.empty?

      valid_order_params.map { |o| "#{order_fields[o.to_a.first.first.to_s]} #{o.to_a.first.last}" }.join(', ')
    else
      { interactions_count: :desc, rating: :desc, updated_at: :desc }
    end
  end

  def page_param
    return 1 unless @params.key?(:pagination) &&
                    @params[:pagination].key?(:page) &&
                    @params[:pagination][:page].present?

    @params[:pagination][:page]
  end

  def per_page_param
    return 10 unless @params.key?(:pagination) &&
                     @params[:pagination].key?(:per_page) &&
                     @params[:pagination][:per_page].present?

    @params[:pagination][:per_page]
  end

  def valid_rate_fields
    %w[
      quick_question_rate
      quick_question_text_rate
      quick_question_video_rate
      video_call_rate
      one_to_one_video_call_rate
      one_to_five_video_call_rate
      extra_user_rate
    ]
  end

  def order_fields
    {
      'name' => 'name',
      'quick_question_rate' => 'experts.quick_question_rate',
      'quick_question_text_rate' => 'experts.quick_question_text_rate',
      'quick_question_video_rate' => 'experts.quick_question_video_rate',
      'video_call_rate' => 'experts.video_call_rate',
      'one_to_one_video_call_rate' => 'experts.one_to_one_video_call_rate',
      'one_to_five_video_call_rate' => 'experts.one_to_five_video_call_rate',
      'extra_user_rate' => 'experts.extra_user_rate',
      'rating' => 'experts.rating',
      'reviews_count' => 'experts.reviews_count'
    }
  end
end
