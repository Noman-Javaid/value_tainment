require 'rails_helper'

describe Payments::RefundsJob do
  include_context 'with transfer creation constants stubs'
  include_context 'with refund data for interaction'

  let(:perform_now) { described_class.perform_now }
  let(:initial_date) { 5.days.ago }
  let(:event_time) { 1.hour.from_now }
  let(:amount) { interaction.rate * usd_currency_factor }

  before do
    Timecop.freeze(initial_date)
    interaction
    Timecop.return
  end

  context 'when changes the interaction to refunded state' do
    include_context 'with stripe mocks and stubs for successful refund creation'

    before do
      perform_now
      interaction.reload
    end

    context 'when interaction is a quick question' do
      context 'with expired state' do
        let(:interaction) { create(:quick_question, :expired, answer_date: event_time) }

        it { expect(interaction).to be_refunded }
      end
    end

    context 'when interaction is an expert call' do
      context 'with expired state' do
        let(:interaction) { create(:expert_call, :expired, scheduled_time_start: event_time) }

        it { expect(interaction).to be_refunded }
      end

      context 'with declined state' do
        let(:interaction) do
          create(:expert_call, :declined, scheduled_time_start: event_time)
        end

        it { expect(interaction).to be_refunded }
      end
    end
  end

  context 'when changes the interaction to unrefunded_for_incompleted_event state' do
    include_context 'with stripe mocks and stubs for refund creation with '\
                    'invalid request error'

    before do
      perform_now
      interaction.reload
    end

    context 'when interaction is a quick question' do
      context 'with expired state' do
        let(:interaction) { create(:quick_question, :expired, answer_date: event_time) }

        it { expect(interaction).to be_unrefunded_for_incompleted_event }
      end
    end

    context 'when interaction is an expert call' do
      context 'with declined state' do
        let(:interaction) { create(:expert_call, :declined, scheduled_time_start: event_time) }

        it { expect(interaction).to be_unrefunded_for_incompleted_event }
      end

      context 'with expired state' do
        let(:interaction) do
          create(:expert_call, :expired, scheduled_time_start: event_time)
        end

        it { expect(interaction).to be_unrefunded_for_incompleted_event }
      end
    end
  end
end
