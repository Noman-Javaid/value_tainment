require 'rails_helper'

describe Payments::ConfirmAndTransferJob do
  include_context 'with transfer creation constants stubs'
  include_context 'with transfer data for interaction'

  let(:perform_now) { described_class.perform_now }
  let(:initial_date) { 5.days.ago }
  let(:event_time) { 1.hour.from_now }

  before do
    Timecop.freeze(initial_date)
    interaction
    Timecop.return
  end

  context 'when changes the interaction to transfered state' do
    include_context 'with stripe mocks and stubs for successful transfer creation'

    before do
      perform_now
      interaction.reload
    end

    context 'when interaction is a quick question' do
      context 'with answered state' do
        let(:interaction) { create(:quick_question, :answered, answer_date: event_time) }

        it { expect(interaction).to be_transfered }
      end

      context 'with denied_complaint state' do
        let(:interaction) do
          create(:quick_question, :denied_complaint, answer_date: event_time)
        end

        it { expect(interaction).to be_transfered }
      end
    end

    context 'when interaction is an expert call' do
      context 'with finished state' do
        let(:interaction) { create(:expert_call, :finished, scheduled_time_start: event_time) }

        it { expect(interaction).to be_transfered }
      end

      context 'with denied_complaint state' do
        let(:interaction) do
          create(:expert_call, :denied_complaint, scheduled_time_start: event_time)
        end

        it { expect(interaction).to be_transfered }
      end
    end
  end

  context 'when changes the interaction to untransferred state' do
    include_context 'with stripe mocks and stubs for transfer creation with '\
                    'invalid request error'

    before do
      perform_now
      interaction.reload
    end

    context 'when interaction is a quick question' do
      context 'with answered state' do
        let(:interaction) { create(:quick_question, :answered, answer_date: event_time) }

        it { expect(interaction).to be_untransferred }
      end

      context 'with denied_complaint state' do
        let(:interaction) do
          create(:quick_question, :denied_complaint, answer_date: event_time)
        end

        it { expect(interaction).to be_untransferred }
      end
    end

    context 'when interaction is an expert call' do
      context 'with finished state' do
        let(:interaction) { create(:expert_call, :finished, scheduled_time_start: event_time) }

        it { expect(interaction).to be_untransferred }
      end

      context 'with denied_complaint state' do
        let(:interaction) do
          create(:expert_call, :denied_complaint, scheduled_time_start: event_time)
        end

        it { expect(interaction).to be_untransferred }
      end
    end
  end
end
