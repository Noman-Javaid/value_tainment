module SESConnector
  module_function

  def client
    @@ses_client ||= Aws::SES::Client.new( # rubocop:todo Style/ClassVars
      region: ENV['AWS_REGION'],
      access_key_id: ENV['AWS_ACCESS_KEY'],
      secret_access_key: ENV['AWS_SECRET_KEY']
    )
  end
end
