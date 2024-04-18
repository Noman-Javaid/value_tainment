class Aws::Buckets::Objects::PresignedUrl < AwsService
  def initialize(bucket_name, object_key, method = :get, attachment = nil)
    super()
    @bucket_name = bucket_name
    @object_key = object_key
    @method = method || DEFAULT_METHOD
    @attachment = attachment
  end

  def call
    bucket = retrieve_bucket
    response = url_hash(bucket)
    return response if @method == :get

    response[:headers] = upload_headers
    response
  rescue StandardError => e
    Rails.logger.info("Errors Generating Presigned Url Service -> #{e}")
    Honeybadger.notify(
      error_message: e, error_class: self.class.to_s,
      context: { bucket_name: @bucket_name, object_key: @object_key, method: @method.to_s }
    )
    nil
  end

  private

  def url_hash(bucket)
    url = bucket.object(@object_key).presigned_url(@method, expires_in: URL_EXPIRATION_TIME.to_i)
    {
      url: url,
      headers: nil
    }
  end

  def upload_headers
    return nil unless @attachment

    filename = @attachment.file_name
    {
      'Content-Type': @attachment.file_type,
      'Content-Disposition': "inline; filename=\"#{filename}\"; filename*=UTF-8''#{filename}"
    }
  end
end
