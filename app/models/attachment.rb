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
class Attachment < ApplicationRecord
  ## Constants
  BUCKET_NAME = Rails.application.credentials.dig(
    Rails.env.to_sym, :aws, :bucket_questions
  )
  URL_EXPIRE_TIME = 10.minutes
  VALID_FILE_SIZE_LIMIT = 110
  VALID_FILE_TYPES = %w[
    audio/aac
    audio/m4a
    audio/wav
    image/png
    image/jpg
    audio/mp4
    audio/MPA
    video/mp4
    audio/mpeg
    image/jpeg
    text/plain
    audio/wave
    audio/x-m4a
    audio/x-wav
    text/markdown
    audio/vnd.wave
    video/quicktime
    application/pdf
    audio/mpa-robust
    application/x-pdf
    application/msword
    application/x-bzpdf
    application/x-gzpdf
    application/vnd.ms-excel
    application/vnd.ms-powerpoint
    application/vnd.oasis.opendocument.text
    application/vnd.oasis.opendocument.spreadsheet
    application/vnd.oasis.opendocument.presentation
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
    application/vnd.openxmlformats-officedocument.presentationml.presentation
  ].freeze
  VALID_STATUS_TO_UPLOAD_FILES = %w[draft_answered].freeze

  attr_accessor :url

  ## Associations
  belongs_to :quick_question, optional: true
  belongs_to :message, optional: true
  ## Validations
  validates :file_name, presence: true, length: { maximum: 100 }
  validates :file_key, presence: true
  validates :file_type, presence: true,
                        inclusion: { in: VALID_FILE_TYPES, message: 'is invalid' }
  validates :file_size, presence: true,
                        numericality: {
                          greater_than: 0,
                          less_than: VALID_FILE_SIZE_LIMIT.megabytes,
                          message: "must be less than #{VALID_FILE_SIZE_LIMIT} megabytes"
                        }

  ## Callbacks
  before_validation :set_file_key, on: [:create, :update], if: :file_name_changed?
  before_save :sanitize_file_name, if: :file_name_changed?
  before_destroy :purge

  ## Methods and helpers
  def purge
    return unless in_bucket?

    Aws::Buckets::Objects::Delete.call(BUCKET_NAME, file_key)
    toggle!(:in_bucket) # rubocop:todo Rails/SkipsModelValidations
  end

  def file_size_description
    size = file_size.to_f
    if size < 1.kilobyte
      "#{size.to_i} Bytes"
    elsif size < 1.megabyte
      "#{(size / 1.kilobyte).round(2)} KB"
    elsif size < 1.gigabyte
      "#{(size / 1.megabyte).round(2)} MB"
    end
  end

  def generate_presigned_url
    self.url = Aws::Buckets::Objects::PresignedUrl.call(
      BUCKET_NAME, file_key, :put, self
    )
  end

  def file_type_extension
    file_name.split('.').last
  end

  def get_attachment_url # rubocop:todo Naming/AccessorMethodName
    return unless in_bucket?

    self.url = Aws::Buckets::Objects::PresignedUrl.call(
      BUCKET_NAME, file_key, :get
    )
  end

  private

  def set_file_key
    self.file_key = "#{quick_question_id}/#{file_name}" if quick_question.present?
    self.file_key = "#{message_id}/#{file_name}" if message_id.present?
  end

  def sanitize_file_name
    file_name.gsub!(/[^0-9A-Za-z.\-]/, '_')
  end
end
