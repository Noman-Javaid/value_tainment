require 'rails_helper'

describe Stripes::Transfers::TransferInteractionAmountHandler do
  subject { transfer_interaction_amount_handler_service.call }

  let(:transfer_interaction_amount_handler_service) { described_class.new(interaction) }

  describe '#call' do
    context 'when interaction is nil' do
      include_context 'with stripe mocks and stubs for transfers creation success'
      let(:interaction) { nil }

      before { subject } # rubocop:todo RSpec/NamedSubject

      it_behaves_like 'service not called', Stripe::Transfer, :create
    end

    context 'when interaction is not nil' do
      let(:error_method) { :api_error }
      let(:service_error_message) { error_message }
      let(:error_object) { OpenStruct.new(api_error: service_error_message) }
      let(:retry_number) { 1 }

      context 'when there is an api rate limit error' do
        include_context 'with stripe mocks and stubs for transfer creation with '\
                        'rate limit error'
        let(:retry_number) { 3 }

        context 'with quick question interaction' do
          let(:interaction) { create(:quick_question) }

          it_behaves_like 'stripe transfer error and retries'
        end

        context 'with expert_call interaction' do
          let(:interaction) { create(:expert_call) }

          it_behaves_like 'stripe transfer error and retries'
        end
      end

      context 'when there is an authentication error' do
        include_context 'with stripe mocks and stubs for transfer creation with '\
                        'authentication error'

        context 'with quick question interaction' do
          let(:interaction) { create(:quick_question) }

          it_behaves_like 'stripe transfer error and retries'
        end

        context 'with expert_call interaction' do
          let(:interaction) { create(:expert_call) }

          it_behaves_like 'stripe transfer error and retries'
        end
      end

      context 'when there is an api connection error' do
        include_context 'with stripe mocks and stubs for transfer creation with '\
                        'api connection error'
        let(:retry_number) { 3 }

        context 'with quick question interaction' do
          let(:interaction) { create(:quick_question) }

          it_behaves_like 'stripe transfer error and retries'
        end

        context 'with expert_call interaction' do
          let(:interaction) { create(:expert_call) }

          it_behaves_like 'stripe transfer error and retries'
        end
      end

      context 'when there is a stripe error' do
        include_context 'with stripe mocks and stubs for transfer creation with '\
                        'stripe error'
        let(:error_method) { :error }
        let(:service_error_message) { "Transfer service error occurred: #{error_message}" }
        let(:error_object) { OpenStruct.new(error: service_error_message) }

        context 'with quick question interaction' do
          let(:interaction) { create(:quick_question) }

          it_behaves_like 'stripe transfer error and retries'
        end

        context 'with expert_call interaction' do
          let(:interaction) { create(:expert_call) }

          it_behaves_like 'stripe transfer error and retries'
        end
      end

      context 'when there is a card error' do
        include_context 'with stripe mocks and stubs for transfer creation with '\
                        'card error'
        let(:error_method) { :error }
        let(:service_error_message) { "A transfer error occurred: #{error_message}" }
        let(:error_object) { OpenStruct.new(error: service_error_message) }

        context 'with quick question interaction' do
          let(:interaction) { create(:quick_question) }

          it_behaves_like 'stripe transfer error and retries'
        end

        context 'with expert_call interaction' do
          let(:interaction) { create(:expert_call) }

          it_behaves_like 'stripe transfer error and retries'
        end
      end

      context 'when there is an invalid request error' do
        include_context 'with stripe mocks and stubs for transfer creation with '\
                        'invalid request error'

        context 'with quick question interaction' do
          let(:interaction) { create(:quick_question) }

          it_behaves_like 'stripe transfer error and retries'
        end

        context 'with expert_call interaction' do
          let(:interaction) { create(:expert_call) }

          it_behaves_like 'stripe transfer error and retries'
        end
      end

      context 'when the transfer is created successfully' do
        include_context 'with stripe mocks and stubs for successful transfer creation'
        include_context 'with transfer creation constants stubs'
        include_context 'with transfer data for interaction'

        let(:interaction_rate) { 300 }
        let(:individual) do
          create(:individual, :with_profile, stripe_customer_id: customer_id)
        end

        context 'with quick question interaction' do
          let(:expert) do
            create(:expert, :with_profile, stripe_account_id: account_id,
                                           quick_question_rate: interaction_rate)
          end
          let(:interaction) do
            create(:quick_question, individual: individual, expert: expert,
                                    rate: interaction_rate,
                                    stripe_payment_method_id: payment_method_id)
          end

          it_behaves_like 'stripe api transfer creation successful'
        end

        context 'with expert_call interaction' do
          let(:expert_interaction_rate) { interaction_rate / scheduled_call_duration }
          let(:expert) do
            create(:expert, :with_profile, stripe_account_id: account_id,
                                           one_to_one_video_call_rate: expert_interaction_rate)
          end
          let(:scheduled_call_duration) { 15 }
          let(:interaction) do
            create(:expert_call, individual: individual, expert: expert,
                                 rate: interaction_rate,
                                 stripe_payment_method_id: payment_method_id,
                                 scheduled_call_duration: scheduled_call_duration)
          end

          it_behaves_like 'stripe api transfer creation successful'
        end
      end
    end
  end

  describe '.call' do
    subject { described_class.call(interaction) }

    let(:service) { double('transfer_interaction_amount_handler_service') } # rubocop:todo RSpec/VerifiedDoubles
    let(:interaction) { nil }

    it_behaves_like 'class service called'
  end
end
