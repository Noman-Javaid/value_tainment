# == Schema Information
#
# Table name: private_chats
#
#  id                :uuid             not null, primary key
#  created_by        :uuid
#  description       :string
#  expiration_date   :datetime
#  name              :string
#  participant_count :integer          default(2), not null
#  short_description :string
#  status            :string           default("pending"), not null
#  users_list        :string           default([]), is an Array
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  expert_id         :uuid             not null
#  individual_id     :uuid             not null
#
# Indexes
#
#  index_private_chats_on_expert_id      (expert_id)
#  index_private_chats_on_individual_id  (individual_id)
#
# Foreign Keys
#
#  fk_rails_...  (expert_id => experts.id)
#  fk_rails_...  (individual_id => individuals.id)
#
require 'rails_helper'

RSpec.describe PrivateChat, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
