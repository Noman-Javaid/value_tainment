RSpec.shared_examples_for 'stripe transfer error and retries' do
  it 'returns error object' do
    expect(subject).to eq(error_object)
  end

  it 'responds to error_method' do
    expect(subject).to respond_to(error_method)
  end

  it 'matches the error message' do
    expect(subject.send(error_method)).to eq(service_error_message)
  end

  it 'stripe service is called retry_number of times' do
    subject
    expect(Stripe::Transfer).to(
      have_received(:create).with(any_args).exactly(retry_number)
    )
  end
end
