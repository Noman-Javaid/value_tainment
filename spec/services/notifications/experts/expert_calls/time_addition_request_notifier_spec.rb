require 'rails_helper'

describe Notifications::Experts::ExpertCalls::TimeAdditionRequestNotifier do
  subject { time_addition_notifier.execute }

  let(:time_addition) { create(:time_addition) }
  let(:time_addition_notifier) { described_class.new(time_addition) }
  let(:message) { 'Requested Time Addition' }

  include_context('with notification job')

  context 'when service responds to execute' do
    it { expect(time_addition_notifier).to respond_to(:execute) }
  end

  context 'when expert allow notifications' do
    before do
      time_addition.expert_call.expert.user.update!(allow_notifications: true)
    end

    context 'when individual has an Android phone' do
      let(:device) do
        create(:device, :with_android, user: time_addition.expert_call.expert.user)
      end

      it 'executes the notification job' do
        expect(PushNotification::SenderJob).to(
          # rubocop:todo RSpec/MessageSpies
          receive(:perform_later).with(device, message, silent, with_sound, payload_data)
          # rubocop:enable RSpec/MessageSpies
        )
        subject # rubocop:todo RSpec/NamedSubject
      end
    end

    context 'when individual has an iOS phone' do
      let(:device) do
        create(:device, :with_ios, user: time_addition.expert_call.expert.user)
      end

      it 'executes the notification job' do
        expect(PushNotification::SenderJob).to(
          receive(:perform_later).with(device, message, job_params) # rubocop:todo RSpec/MessageSpies
        )
        subject # rubocop:todo RSpec/NamedSubject
      end
    end
  end

  context 'when expert do not allow notifications' do
    before do
      time_addition.expert_call.expert.user.update!(allow_notifications: false)
    end

    it 'does not executes the notification job' do
      expect(PushNotification::SenderJob).not_to(
        receive(:perform_later) # rubocop:todo RSpec/MessageSpies
      )
      subject # rubocop:todo RSpec/NamedSubject
    end
  end
end
