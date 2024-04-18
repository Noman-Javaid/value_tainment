RSpec.shared_examples_for 'it raises an InvalidTransition error' do |method|
  it { expect { interaction.send(method) }.to raise_error(AASM::InvalidTransition) }
end

RSpec.shared_examples_for 'it does not raise an error' do |method|
  it { expect { interaction.send(method) }.not_to raise_error }
end
