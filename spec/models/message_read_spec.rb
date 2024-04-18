# == Schema Information
#
# Table name: message_reads
#
#  id          :uuid             not null, primary key
#  reader_type :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  message_id  :uuid
#  reader_id   :uuid
#
# Indexes
#
#  index_message_reads_on_message_id  (message_id)
#  index_message_reads_on_reader      (reader_type,reader_id)
#
require 'rails_helper'

RSpec.describe MessageRead, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
