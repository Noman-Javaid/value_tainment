# == Schema Information
#
# Table name: time_additions
#
#  id             :uuid             not null, primary key
#  duration       :integer
#  payment_status :string
#  rate           :integer
#  status         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  expert_call_id :uuid             not null
#  payment_id     :string
#
# Foreign Keys
#
#  fk_rails_...  (expert_call_id => expert_calls.id)
#
require 'rails_helper'

RSpec.describe TimeAddition, type: :model do
  let(:time_addition) { create(:time_addition) }

  describe 'associations' do
    it { is_expected.to belong_to(:expert_call) }
    it { is_expected.to have_many(:alerts).dependent(:destroy) }
    it { is_expected.to have_many(:refunds).dependent(:destroy) }
    it { is_expected.to have_many(:transfers).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:rate) }
    it { is_expected.to validate_presence_of(:duration) }

    it 'validates inclusion of duration' do
      expect(subject).to validate_inclusion_of(:duration).in_array(# rubocop:todo RSpec/NamedSubject
        [TimeAddition::DEFAULT_DURATION, TimeAddition::DURATION]
      )
    end
  end

  it 'has a valid factory object' do
    expect(time_addition).to be_valid
  end

  describe 'rate setup' do
    let(:time_addition) { create(:time_addition, expert_call: expert_call) }
    let(:expected_rate) { (time_addition.duration / 60) * expert_rate_per_minute }

    context 'with a 1-1 expert call' do
      let(:expert_call) { create(:expert_call) }
      let(:expert_rate_per_minute) do
        time_addition.expert_call.expert.video_call_rate
      end

      it 'match the expected rate' do
        expect(time_addition.rate).to eq(expected_rate)
      end
    end

    context 'with a 1-5 expert call and no extra user' do
      let(:expert_call) { create(:expert_call, :with_1to5) }
      let(:expert_rate_per_minute) do
        time_addition.expert_call.expert.one_to_five_video_call_rate
      end

      it 'match the expected rate' do
        expect(time_addition.rate).to eq(expected_rate)
      end
    end
  end

  describe 'state machine transitioning' do
    include_context 'account balance calculator mocks'
    include_context 'with stripe mocks and stubs for successful refund creation'
    include_context 'with refund data for interaction'
    include_context 'with stripe mocks and stubs for successful transfer creation'
    include_context 'with transfer creation constants stubs'
    include_context 'with transfer data for interaction'
    include_context 'refund event'

    let(:method_name) { nil }
    let(:interaction) { time_addition }
    let(:transaction_event) do
      Transaction.find_by(expert_interaction: interaction.expert_call.expert_interaction)
    end

    context 'when has initial state' do
      it 'has "pending" status' do
        expect(interaction).to be_pending
      end
    end

    context 'when changed from pending to declined state' do
      before { interaction.decline }

      it { expect(interaction).to be_declined }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from pending to confirmed state' do
      let(:method_name) { :add_time_addition_rate_to_expert_pending_events }

      before {
      stub_request(:post, "https://api.stripe.com/v1/payment_intents/pi_xxx/capture").to_return(status: 200, body: "", headers: {})
      interaction.update!(payment_id: 'pi_xxx')
      interaction.confirm
      }

      it { expect(interaction).to be_confirmed }
      it { expect(account_balance_calculator).to have_received(:call).once }
    end

    context 'when changed from pending to refunded state' do
      it 'raised an AASM::InvalidTransition Exception' do
        expect { interaction.refund }.to raise_error(AASM::InvalidTransition)
      end
    end

    context 'when changed from pending to transfered state' do
      it 'raised an AASM::InvalidTransition Exception' do
        expect { interaction.transfer }.to raise_error(AASM::InvalidTransition)
      end
    end

    context 'when changed from declined to refunded state' do
      before { interaction.update(status: 'declined') }

      it 'raised an AASM::InvalidTransition Exception' do
        expect { interaction.refund }.to raise_error(AASM::InvalidTransition)
      end
    end

    context 'when changed from declined to transfered state' do
      before { interaction.update(status: 'declined') }

      it 'raised an AASM::InvalidTransition Exception' do
        expect { interaction.transfer }.to raise_error(AASM::InvalidTransition)
      end
    end

    context 'when changed from confirmed to refunded state' do # rubocop:todo RSpec/RepeatedExampleGroupDescription
      let(:method_name) { :subtract_time_addition_rate_to_expert_pending_events }

      before do
        interaction.update(status: 'confirmed')
        interaction.refund
      end

      it { expect(interaction).to be_refunded }
      it { expect(account_balance_calculator).to have_received(:call).once }

      it_behaves_like 'has a refund transaction'
    end

    context 'when changed from confirmed to transfered state' do
      before do
        interaction.update(status: 'confirmed')
        interaction.transfer
      end

      it { expect(interaction).to be_transferred }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from confirmed to untransferred state' do
      before do
        interaction.update(status: 'confirmed')
        interaction.untransfer
      end

      it { expect(interaction).to be_untransferred }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from confirmed to unrefunded state' do
      before do
        interaction.update(status: 'confirmed')
        interaction.unrefund
      end

      it { expect(interaction).to be_unrefunded }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from untransferred to transferred state' do
      before do
        interaction.update(status: 'untransferred')
        interaction.set_as_transfer
      end

      it { expect(interaction).to be_transferred }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from confirmed to refunded state' do # rubocop:todo RSpec/RepeatedExampleGroupDescription
      let(:method_name) { :subtract_time_addition_rate_to_expert_pending_events }

      before do
        interaction.update(status: 'confirmed')
        interaction.set_refund
      end

      it { expect(interaction).to be_refunded }
      it { expect(account_balance_calculator).to have_received(:call).once }

      it_behaves_like 'does not have a refund transaction'
    end

    context 'when changed from unrefunded to refunded state' do
      let(:method_name) { :subtract_time_addition_rate_to_expert_pending_events }

      before do
        interaction.update(status: 'unrefunded')
        interaction.set_refund
      end

      it { expect(interaction).to be_refunded }
      it { expect(account_balance_calculator).to have_received(:call).once }

      it_behaves_like 'does not have a refund transaction'
    end

    context 'when the refund is successful' do
      let(:method_name) { :subtract_time_addition_rate_to_expert_pending_events }

      before do
        interaction.update(status: 'confirmed')
      end

      it { expect { interaction.refund }.to change(Refund, :count).by(1) }
    end

    context 'when the refund is not successful' do
      include_context 'with stripe mocks and stubs for refund creation with '\
                      'api connection error'
      let(:method_name) { :subtract_time_addition_rate_to_expert_pending_events }

      before do
        interaction.update(status: 'confirmed')
      end

      it 'raised an AASM::InvalidTransition Exception and Create a new Alert' do
        expect { interaction.refund }.to raise_error(AASM::InvalidTransition).and change(Alert, :count).by(1)
      end
    end
  end

  describe '#display_name' do
    it { expect(time_addition.display_name).to eq(time_addition.expert_call.title) }
  end

  describe 'scopes' do
    let(:pending_time_additions_without_payment_data) { create_list(:time_addition, 2) }
    let(:pending_time_additions_with_payment_data) do
      create_list(:time_addition, 2, :with_payment_data)
    end

    describe '.with_payment' do
      before do
        pending_time_additions_without_payment_data
        pending_time_additions_with_payment_data
      end

      it 'returns all calls with payment id' do
        expect(described_class.with_payment).to(
          match_array(pending_time_additions_with_payment_data)
        )
      end
    end

    describe '.with_payment_success' do
      before do
        pending_time_additions_without_payment_data
        pending_time_additions_with_payment_data
      end

      it 'returns all calls with payment status succeeded' do
        expect(described_class.with_payment_success).to(
          match_array(pending_time_additions_with_payment_data)
        )
      end
    end
  end
end
