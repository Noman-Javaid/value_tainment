class UploadContract < Dry::Validation::Contract
  params do
    required(:byte_size).filled(:integer)
    required(:checksum).filled(:string)
    required(:content_type).filled(:string)
    required(:filename).filled(:string)
    optional(:metadata).hash
  end

  rule(:byte_size) do
    key.failure("must be less than #{Attachment::VALID_FILE_SIZE_LIMIT} megabytes") if value > Attachment::VALID_FILE_SIZE_LIMIT.megabytes
  end

  rule(:content_type) do
    key.failure('has invalid type') unless Attachment::VALID_FILE_TYPES.include?(value)
  end
end
