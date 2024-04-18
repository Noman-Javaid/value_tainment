class Aws::Buckets::Objects::Delete < AwsService
  def initialize(bucket_name, object_key)
    super()
    @bucket_name = bucket_name
    @object_key = object_key
  end

  def call
    bucket = retrieve_bucket
    bucket.object(@object_key).delete
    true
  rescue StandardError => e
    Rails.logger.info("Errors Deleting File in S3 Service -> #{e}")
    Honeybadger.notify(
      error_message: e, error_class: self.class.to_s,
      context: { bucket_name: @bucket_name, object_key: @object_key }
    )
    false
  end
end
