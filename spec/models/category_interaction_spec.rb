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
require 'rails_helper'

RSpec.describe CategoryInteraction, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
