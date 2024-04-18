# == Schema Information
#
# Table name: category_interactions
#
#  id               :bigint           not null, primary key
#  interaction_type :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  category_id      :bigint           not null
#  interaction_id   :bigint           not null
#
# Foreign Keys
#
#  fk_rails_...  (category_id => categories.id)
#
class CategoryInteraction < ApplicationRecord
  ## Associations
  belongs_to :category, counter_cache: :interactions_count
  belongs_to :interaction, polymorphic: true
end
