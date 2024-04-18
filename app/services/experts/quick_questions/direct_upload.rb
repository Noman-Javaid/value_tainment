class Experts::QuickQuestions::DirectUpload
  EXPIRE_TIME = 10
  UPLOAD_FILE_METHOD = :put

  def initialize(quick_question, params)
    @quick_question = quick_question
    @params = params.to_h.merge(service_hash)
  end

  def call
    invalid_blob = validate_params
    return invalid_blob if invalid_blob

    @quick_question.attachment.answer_file.purge if @quick_question.attachment&.answer_file&.attached?
    blob = ActiveStorage::Blob.create_before_direct_upload!(
      filename: @params[:filename], byte_size: @params[:byte_size],
      checksum: @params[:checksum], content_type: @params[:content_type],
      service_name: @params[:service_name]
    )
    response = signed_url(blob)
    response[:blob_signed_id] = blob.signed_id
    response
  end

  private

  def signed_url(blob)
    response_signature(
      blob.service_url_for_direct_upload(expires_in: EXPIRE_TIME.minutes),
      headers: blob.service_headers_for_direct_upload
    )
  end

  def service_hash
    { service_name: Attachment::STORAGE_SERVICE.to_s }
  end

  def validate_params
    validation = UploadContract.new.call(@params)
    return unless validation.failure?

    {
      errors: error_message(validation.errors.to_hash)
    }
  end

  def error_message(errors)
    errors.map do |key, value|
      value.map { |v| "#{key} #{v}" }.join
    end.join(', ')
  end

  def response_signature(url, **params)
    {
      direct_upload: {
        url: url
      }.merge(params)
    }
  end
end
