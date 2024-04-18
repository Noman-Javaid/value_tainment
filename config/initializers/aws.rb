require 'aws-sdk-s3'

# In case of need to use api calls to aws
Aws.config.update(
  region: Rails.application.credentials.dig(Rails.env.to_sym, :aws, :region),
  credentials: Aws::Credentials.new(
    Rails.application.credentials.dig(Rails.env.to_sym, :aws, :access_key_id),
    Rails.application.credentials.dig(Rails.env.to_sym, :aws, :secret_access_key)
  )
)
