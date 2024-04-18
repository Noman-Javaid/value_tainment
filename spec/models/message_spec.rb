# == Schema Information
#
# Table name: messages
#
#  id              :uuid             not null, primary key
#  answer_type     :string           default("text")
#  content_type    :string
#  sender_type     :string           not null
#  status          :string           default("sent")
#  text            :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  attachment_id   :bigint
#  private_chat_id :uuid             not null
#  sender_id       :uuid             not null
#
# Indexes
#
#  index_messages_on_attachment_id    (attachment_id)
#  index_messages_on_private_chat_id  (private_chat_id)
#  index_messages_on_sender           (sender_type,sender_id)
#
# Foreign Keys
#
#  fk_rails_...  (attachment_id => attachments.id)
#  fk_rails_...  (private_chat_id => private_chats.id)
#
require 'rails_helper'

RSpec.describe Message, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
