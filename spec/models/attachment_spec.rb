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
require 'rails_helper'

RSpec.describe Attachment, type: :model do
  let(:attachment) { build(:attachment) }
  let(:filename) { 'icon.txt' }
  let(:invalid_type_filename) { 'test_file_rtf.rtf' }


  describe 'valid factory' do
    it { expect(attachment).to be_valid }
  end

  describe 'validations' do
    describe 'when has invalid file type' do
      before do
        attachment.file_type = 'application/rtf'
        attachment.valid?
      end

      it 'has error message' do
        expect(attachment.errors.full_messages).to include('File type is invalid')
      end
    end

    describe 'when has invalid file size' do
      let(:size_limit) { Attachment::VALID_FILE_SIZE_LIMIT }

      before do
        attachment.file_size = (size_limit + 1).megabytes
        attachment.valid?
      end

      it 'has error message' do
        expect(attachment.errors.full_messages).to(
          include("File size must be less than #{size_limit} megabytes")
        )
      end
    end
  end

  describe 'public instance methods' do
    describe 'responds to its methods' do
      it { is_expected.to respond_to(:purge) }
      it { is_expected.to respond_to(:file_size_description) }
    end

    describe 'executes methods correctly' do
      context 'when has file in bucket' do
        describe '#purge' do
          before do
            allow_any_instance_of(Aws::Buckets::Objects::Delete).to( # rubocop:todo RSpec/AnyInstance
              receive(:call).and_return(true)
            )
            attachment.update!(in_bucket: true)
            attachment.purge
          end

          it 'change in_bucket value' do
            expect(attachment).not_to be_in_bucket
          end
        end

        describe '#file_size_description' do
          before do
            attachment.file_size = size
            attachment.in_bucket = true
          end

          context 'when file size is less than 1 KB' do
            let(:size) { 124 }
            let(:result) { "#{size} Bytes" }

            it 'return the size of a file in bytes' do
              expect(attachment.file_size_description).to eq(result)
            end
          end

          context 'when attached file size is less than 1 MB' do
            let(:size) { 505000 }
            let(:result) { "#{(size.to_f / 1.kilobyte).round(2)} KB" }

            it 'return the size of a file in kilobytes' do
              expect(attachment.file_size_description).to eq(result)
            end
          end

          context 'when attached file size is less than 1 GB' do
            let(:size) { 1003741824 }
            let(:result) { "#{(size.to_f / 1.megabyte).round(2)} MB" }

            it 'return the size of a file in megabytes' do
              expect(attachment.file_size_description).to eq(result)
            end
          end
        end
      end
    end
  end
end
