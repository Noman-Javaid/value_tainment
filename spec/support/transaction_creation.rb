RSpec.shared_examples_for 'transaction is created after interaction creation' do
  it { expect { subject }.to change(Transaction, :count).from(0).to(1) }

  it 'transaction with correct charge_type' do
    subject
    expect(transaction).not_to be_nil
  end
end
