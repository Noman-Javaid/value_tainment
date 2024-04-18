require 'rails_helper'

describe Experts::AccountBalanceCalculator do
  subject { account_balance_calculator_service.call }

  RSpec.shared_examples_for 'pending events updated' do
    it 'changes the expert pending_events' do
      expect { subject }.to change(expert, :pending_events)
    end

    it 'matches the expert pending_events with the expected value' do
      subject
      expect(expert.pending_events).to eq(expected_pending_events)
    end
  end

  let(:account_balance_calculator_service) { described_class.new(event, interaction) }

  describe '#call' do
    include_context 'with payment creation constants stubs'

    let(:initial_pending_events) { 100000 }
    let(:pending_value) do
      (interaction.rate * usd_currency_factor * expert_percentage_value).to_i
    end
    let(:expert) do
      create(:expert, :with_profile, pending_events: initial_pending_events)
    end

    context 'with quick_question as the interaction' do
      let(:interaction) { create(:quick_question, expert: expert) }

      context 'with add_rate_to_expert_pending_events as the event' do
        let(:event) { :add_rate_to_expert_pending_events }
        let(:expected_pending_events) { initial_pending_events + pending_value }

        it_behaves_like 'pending events updated'
      end

      context 'with subtract_rate_to_expert_pending_events as the event' do
        let(:event) { :subtract_rate_to_expert_pending_events }
        let(:expected_pending_events) { initial_pending_events - pending_value }

        it_behaves_like 'pending events updated'
      end
    end

    context 'with expert_call as the interaction' do
      let(:interaction) { create(:expert_call, expert: expert) }

      context 'with add_rate_to_expert_pending_events as the event' do
        let(:event) { :add_rate_to_expert_pending_events }
        let(:expected_pending_events) do
          initial_pending_events + pending_value
        end

        it_behaves_like 'pending events updated'
      end

      context 'with subtract_rate_to_expert_pending_events as the event' do
        let(:event) { :subtract_rate_to_expert_pending_events }
        let(:expected_pending_events) { initial_pending_events - pending_value }

        it_behaves_like 'pending events updated'
      end
    end

    context 'with time_addition as the interaction' do
      let(:expert_call) { create(:expert_call, expert: expert) }
      let(:interaction) { create(:time_addition, expert_call: expert_call) }

      context 'with add_time_addition_rate_to_expert_pending_events as the event' do
        let(:event) { :add_time_addition_rate_to_expert_pending_events }
        let(:expected_pending_events) do
          initial_pending_events + pending_value
        end

        it_behaves_like 'pending events updated'
      end

      context 'with subtract_time_addition_rate_to_expert_pending_events as the event' do
        let(:event) { :subtract_time_addition_rate_to_expert_pending_events }
        let(:expected_pending_events) { initial_pending_events - pending_value }

        it_behaves_like 'pending events updated'
      end
    end
  end
end
