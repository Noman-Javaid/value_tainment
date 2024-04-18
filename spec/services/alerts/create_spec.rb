require 'rails_helper'

describe Alerts::Create, type: :service do
  subject do
    described_class.call(
      alert_type: alert_type,
      context: context,
      interaction: interaction,
      message: message,
      send_notification: send_notification
    )
  end

  let(:alert_type) { :refund }
  let(:context) { "SomeClass" }
  let(:interaction) { create(:expert_call) }
  let(:message) { Faker::Lorem.sentence }
  let(:send_notification) { false }

  describe '#call' do
    context 'without required parameters' do
      it 'returns all the experts' do
        expect { described_class.call }.to raise_error(ArgumentError)
      end
    end

    context 'when send_notification is false' do
      before do
        # rubocop:todo RSpec/MessageSpies
        expect(Honeybadger).not_to receive(:notify) # rubocop:todo RSpec/ExpectInHook
        # rubocop:enable RSpec/MessageSpies
      end

      it 'creates a new alert' do
        expect { subject }.to change(Alert, :count).by(1) # rubocop:todo RSpec/NamedSubject
      end
    end

    context 'when send_notification is true' do
      let(:send_notification) { true }

      before do
        # rubocop:todo RSpec/StubbedMock
        # rubocop:todo RSpec/MessageSpies
        expect(Honeybadger).to receive(:notify).and_return(true) # rubocop:todo RSpec/ExpectInHook
        # rubocop:enable RSpec/MessageSpies
        # rubocop:enable RSpec/StubbedMock
      end

      it 'creates a new alert' do
        expect { subject }.to change(Alert, :count).by(1) # rubocop:todo RSpec/NamedSubject
      end
    end
  end
end
