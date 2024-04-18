require 'rails_helper'

describe Stripes::Payments::TimeAdditionPaymentHandler do
  subject { time_addition_payment_handler_service.call }

  let(:time_addition_payment_handler_service) { described_class.new(interaction) }
  let(:account_id) { expert.stripe_account_id }

  describe '#call' do
    context 'when interaction is nil' do
      include_context 'with stripe mocks and stubs for payments creation success'

      let(:interaction) { nil }

      before { subject } # rubocop:todo RSpec/NamedSubject

      it_behaves_like 'service not called', Stripe::PaymentIntent, :create
    end

    context 'when interaction is not nil' do
      let(:error_method) { :api_error }
      let(:service_error_message) { error_message }
      let(:error_object) { OpenStruct.new(api_error: service_error_message) }
      let(:retry_number) { 1 }
      let(:interaction) { create(:time_addition) }

      context 'when there is an api rate limit error' do
        include_context 'with stripe mocks and stubs for payment intent creation with '\
                        'rate limit error'
        let(:retry_number) { 3 }

        it_behaves_like 'stripe error and retries'
      end

      context 'when there is an authentication error' do
        include_context 'with stripe mocks and stubs for payment intent creation with '\
                        'authentication error'

        it_behaves_like 'stripe error and retries'
      end

      context 'when there is an api connection error' do
        include_context 'with stripe mocks and stubs for payment intent creation with '\
                        'api connection error'
        let(:retry_number) { 3 }

        it_behaves_like 'stripe error and retries'
      end

      context 'when there is a stripe error' do
        include_context 'with stripe mocks and stubs for payment intent creation with '\
                        'stripe error'
        let(:error_method) { :error }
        let(:service_error_message) { "Payment service error occurred: #{error_message}" }
        let(:error_object) { OpenStruct.new(error: service_error_message) }

        it_behaves_like 'stripe error and retries'
      end

      context 'when there is a card error' do
        include_context 'with stripe mocks and stubs for payment intent creation with '\
                        'card error'
        let(:error_method) { :error }
        let(:service_error_message) { "A payment error occurred: #{error_message}" }
        let(:error_object) { OpenStruct.new(error: service_error_message) }

        it_behaves_like 'stripe error and retries'
      end

      context 'when there is an invalid request error' do
        include_context 'with stripe mocks and stubs for payment intent creation with '\
                        'invalid request error'

        it_behaves_like 'stripe error and retries'
      end

      context 'when the payment is created successfully' do
        include_context 'with stripe mocks and stubs for successful payment creation'
        include_context 'with payment creation constants stubs'
        include_context 'with payment intent data for time addtion'

        let(:interaction_rate) { 300 }
        let(:individual) do
          create(:individual, :with_profile, stripe_customer_id: customer_id)
        end

        let(:expert_interaction_rate) { interaction_rate / scheduled_call_duration }
        let(:expert) do
          create(:expert, :with_profile, stripe_account_id: account_id,
                                         one_to_one_video_call_rate: expert_interaction_rate,
                                         video_call_rate: expert_interaction_rate)
        end
        let(:scheduled_call_duration) { 15 }
        let(:expert_call) do
          create(:expert_call, individual: individual, expert: expert,
                               rate: interaction_rate,
                               stripe_payment_method_id: payment_method_id,
                               scheduled_call_duration: scheduled_call_duration)
        end
        let(:time_addition_duration) { 15 * 60 }
        let(:interaction) do
          create(:time_addition, expert_call: expert_call, duration: time_addition_duration)
        end

        it_behaves_like 'stripe api payment creation successful'
      end
    end
  end

  describe '.call' do
    subject { described_class.call(interaction) }

    let(:service) { double('time_addition_payment_handler_service') } # rubocop:todo RSpec/VerifiedDoubles
    let(:interaction) { nil }

    it_behaves_like 'class service called'
  end
end
