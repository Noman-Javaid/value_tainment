require 'rails_helper'

describe Stripes::Payments::ConfirmationHandler do
  RSpec.shared_examples_for 'when stripe payment confirmation service' do
    it 'is called' do
      expect(Stripe::PaymentIntent).to(
        have_received(:confirm).with(interaction_payment_id).exactly(1)
      )
    end
  end

  RSpec.shared_context 'when confirms the payment' do
    include_context 'with stripe mocks and stubs for payment confirmation'

    let(:expected_payment_status) { 'succeeded' }

    before { payment_confirmation_handler.call }

    it_behaves_like 'when stripe payment confirmation service'

    it 'completes the payment' do
      expect(interaction).to be_transfered
    end

    it 'creates transaction' do
      expect(transactions.count).to eq(1)
    end

    it 'payment has succeded' do
      expect(interaction.payment_status).to eq(expected_payment_status)
    end
  end

  RSpec.shared_context 'with stripe error in confirmation service' do
    include_context 'with stripe mocks and stubs for payment confirmation error'

    let(:expected_payment_status) { error_message }

    before { payment_confirmation_handler.call }

    it_behaves_like 'when stripe payment confirmation service'

    it 'is not transfered' do
      expect(interaction).not_to be_transfered
    end

    it 'do not creates transaction' do
      expect(transactions.count).to eq(0)
    end

    it 'had error' do
      expect(interaction.payment_status).to eq(expected_payment_status)
    end
  end

  RSpec.shared_context 'with different payment status in confirmation service' do
    include_context 'with stripe mocks and stubs for payment requires_action'

    let(:expected_payment_status) { 'requires_action' }

    before { payment_confirmation_handler.call }

    it_behaves_like 'when stripe payment confirmation service'

    it 'is not transfered' do
      expect(interaction).not_to be_transfered
    end

    it 'do not creates transaction' do
      expect(transactions.count).to eq(0)
    end

    it 'had error' do
      expect(interaction.payment_status).to eq(expected_payment_status)
    end
  end

  let(:payment_confirmation_handler) { described_class.new(interaction) }
  let(:transactions) { interaction.expert.transactions }
  let(:interaction_payment_id) { interaction.payment_id }
  let(:interaction_amount) { interaction.rate * StripeService::USD_CURRENCY_FACTOR }

  # TODO- Update account deletion flow
  xdescribe '#call' do
    context 'when interaction is nil' do
      include_context 'with stripe mocks and stubs for payment confirmation'

      let(:interaction) { nil }
      let(:interaction_payment_id) { nil }
      let(:interaction_amount) { nil }

      before { payment_confirmation_handler.call }

      it_behaves_like 'service not called', Stripe::PaymentIntent, :confirm
    end

    context 'when interaction is not nil' do
      context 'with quick question' do
        context 'with no payment_id' do
          let(:interaction) { create(:quick_question) }

          it 'raises an argument error' do
            expect { payment_confirmation_handler }.to raise_error(ArgumentError)
          end
        end

        context 'with payment_id' do
          let(:interaction) { create(:quick_question, :answered) }

          it_behaves_like 'when confirms the payment'

          context 'when payment fail' do
            it_behaves_like 'with stripe error in confirmation service'
          end

          context 'when payment requires_action' do
            it_behaves_like 'with different payment status in confirmation service'
          end
        end
      end

      context 'with expert call' do
        context 'with no payment_id' do
          let(:interaction) { create(:expert_call) }

          it 'raises an argument error' do
            expect { payment_confirmation_handler }.to raise_error(ArgumentError)
          end
        end

        context 'with payment_id' do
          let(:interaction) { create(:expert_call, :finished) }

          it_behaves_like 'when confirms the payment'

          context 'when payment fail' do
            it_behaves_like 'with stripe error in confirmation service'
          end

          context 'when payment requires_action' do
            it_behaves_like 'with different payment status in confirmation service'
          end
        end
      end
    end
  end
end
