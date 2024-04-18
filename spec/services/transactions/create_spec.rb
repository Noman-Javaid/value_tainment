require 'rails_helper'

describe Transactions::Create do
  subject { described_class.call(interaction, transaction, is_refund) }

  RSpec.shared_examples_for 'transaction created' do
    it 'creates a new transaction' do
      expect { subject }.to change(Transaction, :count).by(1)
    end

    it 'returns a transaction instance' do
      expect(subject).to be_a(Transaction)
    end

    it 'returns a transaction instance with correct charge_type' do
      expect(subject.charge_type).to eq(expected_charge_type)
    end

    it 'returns a transaction instance with correct amount' do
      expect(subject.amount).to eq(amount)
    end
  end

  let(:amount) { 5000 }
  let(:transaction) { OpenStruct.new(id: 'pm_xxxxxxx', amount: amount) }
  let(:expert_call) { create(:expert_call) }
  let(:quick_question) { create(:quick_question) }
  let(:time_addition) { create(:time_addition) }
  let(:is_refund) { false }
  let(:cancelation_charge_type) { 'payment_intent_cancelation' }
  let(:confirmation_charge_type) { 'payment_intent_confirmation' }

  describe '#call' do
    before do
      stub_const('Transaction::CHARGE_TYPE_CONFIRMATION', confirmation_charge_type)
      stub_const('Transaction::CHARGE_TYPE_CANCELATION', cancelation_charge_type)
    end

    context 'without required parameters' do
      it 'raises an error' do
        expect { described_class.call }.to raise_error(ArgumentError)
      end
    end

    context 'when interaction is a quick question' do
      let(:interaction) { quick_question }

      context 'when is_refund is false' do
        let(:expected_charge_type) { confirmation_charge_type }

        it_behaves_like 'transaction created'
      end

      context 'when is_refund is true' do
        let(:expected_charge_type) { cancelation_charge_type }
        let(:is_refund) { true }

        it_behaves_like 'transaction created'
      end
    end

    context 'when interaction is an expert call' do
      let(:interaction) { expert_call }

      context 'when is_refund is false' do
        let(:expected_charge_type) { confirmation_charge_type }

        it_behaves_like 'transaction created'
      end

      context 'when is_refund is true' do
        let(:expected_charge_type) { cancelation_charge_type }
        let(:is_refund) { true }

        it_behaves_like 'transaction created'
      end
    end

    context 'when interaction is a time addition' do
      let(:interaction) { time_addition }

      context 'when is_refund is false' do
        let(:expected_charge_type) { confirmation_charge_type }

        it_behaves_like 'transaction created'

        it 'associated with the time addition' do
          expect(subject.time_addition).to eq(interaction) # rubocop:todo RSpec/NamedSubject
        end
      end

      context 'when is_refund is true' do
        let(:expected_charge_type) { cancelation_charge_type }
        let(:is_refund) { true }

        it_behaves_like 'transaction created'

        it 'associated with the time addition' do
          expect(subject.time_addition).to eq(interaction) # rubocop:todo RSpec/NamedSubject
        end
      end
    end
  end

  describe '.call' do
    subject { described_class.call(interaction, transaction, is_refund) }

    let(:service) { double('time_addition_payment_handler_service') } # rubocop:todo RSpec/VerifiedDoubles
    let(:interaction) { expert_call }

    it_behaves_like 'class service called'
  end
end
