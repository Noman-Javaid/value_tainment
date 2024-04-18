RSpec.shared_context 'list of quick questions' do # rubocop:todo RSpec/ContextWording
  let(:pending_questions_list_with_payment_requires_confirmation) do
    create_list(:quick_question, 2, :with_payment_requires_confirmation,
                individual: individual, expert: expert)
  end
  let(:pending_questions_list_without_payment_data) do
    create_list(:quick_question, 2, :without_payment_data, individual: individual,
                                                           expert: expert)
  end
  let(:expired_questions_list) do
    create_list(:quick_question, 2, :expired, individual: individual, expert: expert)
  end
  let(:pending_questions_list) do
    create_list(:quick_question, 2, individual: individual, expert: expert)
  end
  let(:draft_answered_questions_list) do
    create_list(
      :quick_question, 2, :draft_answered, individual: individual, expert: expert
    )
  end
  let(:answered_questions_list) do
    create_list(:quick_question, 2, :answered, individual: individual, expert: expert)
  end
  let(:filed_complaint_questions_list) do
    create_list(
      :quick_question, 2, :filed_complaint, individual: individual, expert: expert
    )
  end
  let(:transfered_questions_list) do
    create_list(:quick_question, 2, :transfered, individual: individual, expert: expert)
  end
  let(:untransfered_questions_list) do
    create_list(
      :quick_question, 2, :untransferred, individual: individual, expert: expert
    )
  end
  let(:approved_complaint_questions_list) do
    create_list(
      :quick_question, 2, :approved_complaint, individual: individual, expert: expert
    )
  end
  let(:denied_complaint_questions_list) do
    create_list(
      :quick_question, 2, :denied_complaint, individual: individual, expert: expert
    )
  end
  let(:failed_questions_list) do
    create_list(:quick_question, 2, :failed, individual: individual, expert: expert)
  end
  let(:answered_questions) do
    answered_questions_list.size + filed_complaint_questions_list.size +
      transfered_questions_list.size + untransfered_questions_list.size +
      approved_complaint_questions_list.size + denied_complaint_questions_list.size
  end
  let(:pending_questions) do
    pending_questions_list.size + draft_answered_questions_list.size
  end
  let(:all_questions) do
    answered_questions + pending_questions +
      expired_questions_list.size + failed_questions_list.size
  end
end

RSpec.shared_examples_for 'return pending question list' do
  let(:query_params) { {} }

  before do
    pending_questions
    get quick_question_path, headers: auth_headers(user), params: query_params
  end

  it_behaves_like 'success JSON response'

  it_behaves_like 'correct structure response for quick_question not empty'

  it 'returns same quantity of pending QuickQuestions' do
    expect(json['data']['quick_questions'].size).to eq(pending_questions)
  end
end

RSpec.shared_examples_for 'return completed question list' do
  let(:query_params) { { completed: 'true', per_page: 20, page: 1 } }

  before do
    answered_questions
    get quick_question_path, headers: auth_headers(user), params: query_params
  end

  it_behaves_like 'success JSON response'

  it_behaves_like 'correct structure response for quick_question not empty'

  it 'returns same quantity of completed QuickQuestions created for individual user' do
    expect(json['data']['quick_questions'].size).to eq(answered_questions)
  end
end

RSpec.shared_examples_for 'return all question list' do
  let(:query_params) { { previous: 'true', per_page: 20, page: 1 } }

  before do
    all_questions
    get quick_question_path, headers: auth_headers(user), params: query_params
  end

  it_behaves_like 'success JSON response'

  it_behaves_like 'correct structure response for quick_question not empty'

  it 'returns same quantity of all QuickQuestions created for individual user' do
    expect(json['data']['quick_questions'].size).to eq(all_questions)
  end
end

RSpec.shared_examples_for 'return a subset of quick_questions based on pagination' do
  let(:query_params) { { previous: 'true', per_page: 1 } }

  before do
    pending_questions
    get quick_question_path, headers: auth_headers(user), params: query_params
  end

  it_behaves_like 'success JSON response'

  it_behaves_like 'correct structure response for quick_question not empty'

  it 'returns same quantity of all QuickQuestions created for individual user' do
    expect(json['data']['quick_questions'].size).to eq(1)
  end
end

RSpec.shared_examples_for 'return a subset of quick_questions based on limit and offset pagination' do
  let(:query_params) { { previous: 'true', per_page: 1, page: 1 } }

  before do
    pending_questions
    get quick_question_path, headers: auth_headers(user), params: query_params
  end

  it_behaves_like 'success JSON response'

  it_behaves_like 'correct structure response for quick_question not empty'

  it 'returns same quantity of all QuickQuestions created for individual user' do
    expect(json['data']['quick_questions'].size).to eq(1)
  end
end

RSpec.shared_examples_for 'return quick_question with a max limit of pagination' do
  let(:max_pagination) { 10 }
  let(:group_of_questions1) do
    create_list(:quick_question, 6, :answered, individual: individual, expert: expert)
  end
  let(:aux_expert) do
    create(:expert, :with_profile, status: :verified, user: create(:user))
  end
  let(:group_of_questions2) do
    create_list(:quick_question, 6, :answered, individual: individual, expert: aux_expert)
  end
  let(:query_params) { { previous: 'true' } }

  before do
    group_of_questions1
    answered_questions_list
    pending_questions

    group_of_questions2
    get quick_question_path, headers: auth_headers(user), params: query_params
  end

  it_behaves_like 'success JSON response'

  it_behaves_like 'correct structure response for quick_question not empty'

  it 'returns max quantity of all QuickQuestions based on pagination limits' do
    expect(json['data']['quick_questions'].size).to eq(max_pagination)
  end
end
