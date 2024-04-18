RSpec.shared_context 'list of expert calls' do # rubocop:todo RSpec/ContextWording
  let(:requires_confirmation_calls_list_with_payment_requires_confirmation) do
    create_list(:expert_call, 2, :with_payment_requires_confirmation,
                individual: individual, expert: expert)
  end
  let(:requires_confirmation_calls_list_without_payment_data) do
    create_list(:expert_call, 2, :without_payment_data, individual: individual,
                                                        expert: expert)
  end
  let(:requires_confirmation_calls_list) do
    create_list(:expert_call, 2, individual: individual, expert: expert)
  end
  let(:requires_reschedule_confirmation_calls_list) do
    create_list(
      :expert_call, 2, :requires_reschedule_confirmation, individual: individual,
                                                          expert: expert
    )
  end
  let(:scheduled_calls_list) do
    create_list(:expert_call, 2, :scheduled, individual: individual, expert: expert)
  end
  let(:declined_calls_list) do
    create_list(:expert_call, 2, :declined, individual: individual, expert: expert)
  end
  let(:expired_calls_list) do
    create_list(:expert_call, 2, :expired, individual: individual, expert: expert)
  end
  let(:ongoing_calls_list) do
    create_list(:expert_call, 1, :ongoing, individual: individual, expert: expert)
  end
  let(:finished_calls_list) do
    create_list(:expert_call, 1, :finished, individual: individual, expert: expert)
  end
  let(:incompleted_calls_list) do
    create_list(:expert_call, 2, :incompleted, individual: individual, expert: expert)
  end
  let(:transfered_calls_list) do
    create_list(:expert_call, 2, :transfered, individual: individual, expert: expert)
  end
  let(:untransfered_calls_list) do
    create_list(:expert_call, 2, :untransferred, individual: individual, expert: expert)
  end
  let(:refunded_calls_list) do
    create_list(:expert_call, 2, :refunded, individual: individual, expert: expert)
  end
  let(:filed_complaint_calls_list) do
    create_list(:expert_call, 2, :filed_complaint, individual: individual, expert: expert)
  end
  let(:approved_complaint_calls_list) do
    create_list(
      :expert_call, 2, :approved_complaint, individual: individual, expert: expert
    )
  end
  let(:denied_complaint_calls_list) do
    create_list(
      :expert_call, 2, :denied_complaint, individual: individual, expert: expert
    )
  end
  let(:failed_calls_list) do
    create_list(:expert_call, 2, :failed, individual: individual, expert: expert)
  end
  let(:all_calls_size) do
    requires_confirmation_calls_list + requires_reschedule_confirmation_calls_list +
      scheduled_calls_list.size + declined_calls_list.size + expired_calls_list.size +
      ongoing_calls_list.size + finished_calls_list.size + incompleted_calls_list.size +
      transfered_calls_list.size + untransfered_calls_list.size + failed_calls_list.size +
      refunded_calls_list.size + filed_complaint_calls_list.size +
      approved_complaint_calls_list.size + denied_complaint_calls_list.size
  end
end
