require 'rails_helper'

RSpec.describe 'Api::V1::StripeWebhooksController', type: :request do
  let(:webhooks_path) { api_v1_stripe_webhooks_path }
  let(:execute_post) { post webhooks_path, headers: headers, params: event_data.to_json }

  include_context 'Stripe mocks and stubs'

  describe 'POST /stripe_webhooks' do
    context 'with a valid event type' do
      before do
        user = create(:user, :expert)
        user.expert.stripe_account_id = account_id
        user.expert.save
      end

      describe 'event type account.updated' do
        let(:event_data) { account_updated_event }

        it 'returns http success' do
          allow(Stripe::Webhook).to receive(:construct_event).and_return(event_data)

          execute_post

          expect(response).to have_http_status(:success)
        end
      end

      # describe 'event type payment_method.attached' do
      #   let(:event_data) { payment_method_attached_event }

      #   it 'returns http success' do
      #     allow(Stripe::Webhook).to receive(:construct_event).and_return(event_data)

      #     execute_post

      #     expect(response).to have_http_status(:success)
      #   end
      # end

      describe 'event type payout.paid' do
        let(:event_data) { payout_paid_event }

        it 'returns http success' do
          allow(Stripe::Webhook).to receive(:construct_event).and_return(event_data)

          execute_post

          expect(response).to have_http_status(:success)
        end
      end

      describe 'event type account.external_account.created' do
        let(:event_data) { account_external_account_created_event }

        it 'returns http success' do
          allow(Stripe::Webhook).to receive(:construct_event).and_return(event_data)

          execute_post

          expect(response).to have_http_status(:success)
        end
      end
    end

    describe 'unknown Event type' do
      let(:event_data) { unknown_event_type }

      it 'returns http bad request' do
        allow(Stripe::Webhook).to receive(:construct_event).and_return(event_data)

        execute_post

        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'invalid JSON input' do
    it 'returns http bad request' do
      post webhooks_path, headers: headers

      expect(response).to have_http_status(:bad_request)
    end
  end
end
