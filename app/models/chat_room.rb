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
class ChatRoom < ApplicationRecord
  belongs_to :expert_call, optional: true

  enum status: {
    active: 'active',
    closed: 'closed',
    archived: 'archived'
    # Add more status options as needed
  }
end
