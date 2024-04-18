RSpec.shared_context 'finish_expert_call' do # rubocop:todo RSpec/ContextWording
  subject { expert_call.update!(call_time: 1200, time_end: expert_call.scheduled_time_end) }

  let(:expert_call) do
    create(:expert_call, :ongoing, individual: individual, expert: expert)
  end
  let(:id) { expert_call.id }

  before do
    allow_any_instance_of(ExpertCalls::CallFinisher).to( # rubocop:todo RSpec/AnyInstance
      receive(:call).and_return(subject) # rubocop:todo RSpec/NamedSubject
    )
    patch finish_expert_call_path, headers: auth_headers(user)
  end

  it_behaves_like 'success JSON response'

  it 'matches the expected schema' do
    expect(response).to match_json_schema('v1/expert_call/create')
  end
end
