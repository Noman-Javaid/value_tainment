RSpec.shared_context 'with notification job' do
  let(:silent) { true }
  let(:with_sound) { false }
  let(:payload_data) do
    {
      expert_call_id: time_addition.expert_call_id,
      expert_id: time_addition.expert_call.expert_id,
      expert_name: time_addition.expert_call.expert.name,
      individual_id: time_addition.expert_call.individual_id,
      individual_name: time_addition.expert_call.individual.name,
      time_addition_duration: time_addition.duration,
      time_addition_id: time_addition.id,
      time_addition_status: time_addition.status
    }
  end
  let(:job_params) do
    { silent: silent, with_sound: with_sound, payload_data: payload_data }
  end
end

RSpec.shared_examples_for 'notification job with setter have been called n times' do |n|
  it 'returns a correct response' do
    # rubocop:todo RSpec/VerifiedDoubles
    # rubocop:todo RSpec/MessageSpies
    expect(PushNotification::SenderJob).to(receive(:set).exactly(n).and_return(double('scope').tap do |scope|
      # rubocop:enable RSpec/MessageSpies
      # rubocop:enable RSpec/VerifiedDoubles
      expect(scope).to(receive(:perform_later).exactly(n)) # rubocop:todo RSpec/MessageSpies
    end))
    subject
  end
end

RSpec.shared_examples_for 'notification job have not been called' do
  it 'returns a correct response' do
    expect(PushNotification::SenderJob).not_to receive(:set) # rubocop:todo RSpec/MessageSpies
    subject
  end
end

RSpec.shared_examples_for 'notification job with perform_later have been called n times' do |n|
  it 'returns a correct response' do
    expect(PushNotification::SenderJob).to(receive(:perform_later).exactly(n)) # rubocop:todo RSpec/MessageSpies
    subject
  end
end
