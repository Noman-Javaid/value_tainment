# == Schema Information
#
# Table name: attachments
#
#  id                :bigint           not null, primary key
#  file_key          :string           not null
#  file_name         :string           not null
#  file_size         :integer          not null
#  file_type         :string           not null
#  in_bucket         :boolean          default(FALSE), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  message_id        :uuid
#  quick_question_id :uuid
#
# Indexes
#
#  index_attachments_on_message_id  (message_id)
#
# Foreign Keys
#
#  fk_rails_...  (message_id => messages.id)
#  fk_rails_...  (quick_question_id => quick_questions.id)
#
FactoryBot.define do
  factory :attachment do
    association :quick_question
    file_type { 'text/plain' }
    file_name { 'test_file.txt' }
    file_size { 29854 }
  end
end
