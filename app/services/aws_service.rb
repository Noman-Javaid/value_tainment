class AwsService
  URL_EXPIRATION_TIME = 10.minutes

  def initialize
    @s3 = Aws::S3::Resource.new
  end

  def self.call(...)
    new(...).call
  end

  private

  def retrieve_bucket
    @s3.bucket(@bucket_name)
  end
end
