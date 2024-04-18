# == Schema Information
#
# Table name: chat_rooms
#
#  id             :bigint           not null, primary key
#  name           :string
#  room_data      :jsonb
#  sid            :string
#  status         :string           default("active")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  expert_call_id :uuid
#
# Indexes
#
#  index_chat_rooms_on_expert_call_id  (expert_call_id)
#
# Foreign Keys
#
#  fk_rails_...  (expert_call_id => expert_calls.id)
#
require 'rails_helper'

RSpec.describe ChatRoom, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
