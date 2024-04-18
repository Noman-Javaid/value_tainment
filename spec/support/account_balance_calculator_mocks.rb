RSpec.shared_context 'account balance calculator mocks' do # rubocop:todo RSpec/ContextWording
  # rubocop:todo RSpec/VerifiedDoubles
  let(:account_balance_calculator) { double('account_balance_calculator', call: nil) }
  # rubocop:enable RSpec/VerifiedDoubles

  before do
    allow(Experts::AccountBalanceCalculator).to(
      receive(:new).with(method_name, interaction).and_return(account_balance_calculator)
    )
  end
end
