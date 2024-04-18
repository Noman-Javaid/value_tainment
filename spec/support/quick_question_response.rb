RSpec.shared_examples_for 'correct structure response for quick_question' do
  it { expect(json['data']).to include('quick_questions') }

  it 'returns a QuickQuestion Array' do
    expect(json['data']['quick_questions']).to be_an(Array)
  end
end

RSpec.shared_examples_for 'correct structure response for quick_question not empty' do
  it_behaves_like 'correct structure response for quick_question'

  it 'returns a non empty QuickQuestion Array' do
    expect(json['data']['quick_questions']).not_to be_empty
  end
end

RSpec.shared_examples_for 'correct structure response for quick_question empty' do
  it_behaves_like 'correct structure response for quick_question'

  it 'returns an empty QuickQuestion Array' do
    expect(json['data']['quick_questions']).to be_empty
  end
end
