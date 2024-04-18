RSpec.shared_examples_for 'service not called' do |service, method|
  it { expect(service).not_to have_received(method) }
end

RSpec.shared_context 'class service called' do # rubocop:todo RSpec/ContextWording
  before do
    allow(described_class).to(receive(:new).with(any_args).and_return(service))
    allow(service).to(receive(:call).with(no_args).and_return(nil))
    subject # rubocop:todo RSpec/NamedSubject
  end

  it 'calls the instance method call' do
    expect(service).to have_received(:call).with(no_args).exactly(1)
  end
end

RSpec.shared_examples_for 'follow up tracker service is called' do
  it do
    expect(AccountDeletionFollowUps::TrackerHelper).to(
      have_received(:call).with(any_args).exactly(associations.count)
    )
  end
end
