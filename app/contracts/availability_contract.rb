class AvailabilityContract < Dry::Validation::Contract
  params do
    optional(:call_duration).filled(:integer)
  end

  rule(:call_duration) do
    key.failure('has invalid value') if key? && ExpertCall::VALID_CALL_DURATIONS.exclude?(value)
  end
end
