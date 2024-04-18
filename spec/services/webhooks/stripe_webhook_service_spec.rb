require 'rails_helper'

describe Webhooks::StripeWebhookService do
  let(:stripe_webhooks_service) { described_class.new(event) }

  describe '#handle' do
    include_context 'Stripe mocks and stubs'

    describe 'Event type account.updated' do
      let(:event) { account_updated_event }

      it 'does not raise error' do
        allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

        expect { stripe_webhooks_service.handle }.not_to raise_error
      end
    end

    describe 'Event type payout.paid' do
      let(:event) { payout_paid_event }

      it 'does not raise error' do
        allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

        expect { stripe_webhooks_service.handle }.not_to raise_error
      end
    end

    describe 'Event type account.external_account.created' do
      let(:event) { account_external_account_created_event }

      it 'does not raise error' do
        allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

        expect { stripe_webhooks_service.handle }.not_to raise_error
      end
    end

    describe 'Event type payment_method.attached' do
      let(:event) { paymenth_method_attached }

      it 'does not raise error' do
        allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

        expect { stripe_webhooks_service.handle }.not_to raise_error
      end
    end

    describe 'Unknown Event type' do
      let(:event) { unknown_event_type }

      it 'raises Webhooks::Errors::UnhandledEventType' do
        allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

        expect { stripe_webhooks_service.handle }.to raise_error(Webhooks::Errors::UnhandledEventType)
      end
    end
  end
end
