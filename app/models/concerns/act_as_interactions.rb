module ActAsInteractions
  extend ActiveSupport::Concern

  included do
    has_one :category_interaction, dependent: :destroy, as: :interaction
    has_one :expert_interaction, dependent: :destroy, as: :interaction

    after_commit :create_interactions, on: :create
  end

  # creates interactions for categories an expert counts
  def create_interactions
    category_interaction || create_category_interaction!(category: category) if category.present?
    expert_interaction || create_expert_interaction!(expert: expert)
  end
end
