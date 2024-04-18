# == Schema Information
#
# Table name: expert_interactions
#
#  id               :bigint           not null, primary key
#  feedback         :text
#  interaction_type :string           not null
#  rating           :float
#  reviewed_at      :datetime
#  was_helpful      :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  expert_id        :uuid             not null
#  interaction_id   :uuid             not null
#
# Indexes
#
#  index_expert_interactions_on_expert_id    (expert_id)
#  index_expert_interactions_on_interaction  (interaction_type,interaction_id)
#
# Foreign Keys
#
#  fk_rails_...  (expert_id => experts.id)
#
require 'rails_helper'

RSpec.describe ExpertInteraction, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
