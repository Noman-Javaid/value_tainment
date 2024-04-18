RSpec.shared_context 'list of transactions' do # rubocop:todo RSpec/ContextWording
  let(:guest_list_ids) { create_list(:individual, 5, :with_profile).map(&:id) }
  let(:expert_calls) do
    create_list(:expert_call, 2, expert: expert, individual: individual)
  end
  let(:expert_calls_with_guests) do
    create_list(:expert_call, 2, :with_1to5, expert: expert, individual: individual,
                                             guest_ids: guest_list_ids)
  end
  let(:quick_questions) do
    create_list(:quick_question, 2, expert: expert, individual: individual)
  end
  let(:quick_questions_transactions) do
    quick_questions.map do |qq|
      create(:transaction, expert_interaction: qq.expert_interaction, expert: expert,
                           individual: individual)
    end
  end
  let(:expert_calls_transactions) do
    expert_calls.map do |ec|
      create(:transaction, expert_interaction: ec.expert_interaction, expert: expert,
                           individual: individual)
    end
  end
  let(:expert_calls_with_guests_transactions) do
    expert_calls_with_guests.map do |ec|
      create(:transaction, expert_interaction: ec.expert_interaction, expert: expert,
                           individual: individual)
    end
  end
end
