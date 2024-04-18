require 'rails_helper'

describe Notifications::UpcomingEventReminderNotifier do
  subject { described_instance.execute }

  include_context 'expert_call_user_for_notifications'

  let(:reminder_in_fifteen_minutes) { create(:reminder, timer: 0.25) }
  let(:reminder_in_thirteen_minutes) { create(:reminder, timer: 0.5) }
  let(:event_datetime) { '1/May/2022 14:00:00 +00:00'.to_datetime }
  let(:expert_call) do
    create(:expert_call, individual: individual, expert: expert,
                         scheduled_time_start: event_datetime)
  end
  let(:described_instance) { described_class.new(expert_call) }

  before do
    # initialize test with 2 created reminders
    reminder_in_fifteen_minutes
    reminder_in_thirteen_minutes
    # initialize expert and invidual devices
    individual_device
    expert_device
  end

  describe '#execute' do
    describe '30 and 15 minute reminders are in range to send notifications' do
      before do
        # current time of test will be one hour before expert_call take place
        Timecop.freeze(1.hour.ago(event_datetime))
      end

      after { Timecop.return }

      context 'with both expert and individual notifications on' do
        it_behaves_like 'notification job with setter have been called n times', 4

        context 'when 30 minute reminder is inactive' do
          before { reminder_in_thirteen_minutes.update(active: false) }

          it_behaves_like 'notification job with setter have been called n times', 2
        end

        context 'when 15 minute reminder is inactive' do
          before { reminder_in_fifteen_minutes.update(active: false) }

          it_behaves_like 'notification job with setter have been called n times', 2
        end

        context 'when 30 and 15 minute reminders are inactive' do
          before do
            reminder_in_thirteen_minutes.update(active: false)
            reminder_in_fifteen_minutes.update(active: false)
          end

          it_behaves_like 'notification job have not been called'
        end
      end

      context 'when only individual had notifications on' do
        before { expert_user.update(allow_notifications: false) }

        it_behaves_like 'notification job with setter have been called n times', 2
      end

      context 'when only expert had notifications on' do
        before { individual_user.update(allow_notifications: false) }

        it_behaves_like 'notification job with setter have been called n times', 2
      end
    end

    describe 'The fifteen minute reminder is in range to send notifications' do
      let(:fifteen_minute_message) do
        "You have an scheduled call about #{expert_call.title} in 15 minutes"
      end
      let(:fifteen_minute_reminder_date) do
        reminder_in_fifteen_minutes.timer.hours.ago(expert_call.scheduled_time_start)
      end
      let(:fifteen_minute_reminder_hash) { { wait_until: fifteen_minute_reminder_date } }

      before do
        # current time of test will be 20 minutes before expert_call take place
        Timecop.freeze(20.minutes.ago(event_datetime))
      end

      after { Timecop.return }

      context 'with both expert and individual notifications on' do
        it_behaves_like 'notification job with setter have been called n times', 2
      end

      context 'when only individual has notifications on' do
        before { expert_user.update(allow_notifications: false) }

        it_behaves_like 'notification job with setter have been called n times', 1

        it 'notification job with proper arguments' do
          # rubocop:todo RSpec/VerifiedDoubles
          # rubocop:todo RSpec/StubbedMock
          # rubocop:todo RSpec/MessageSpies
          expect(PushNotification::SenderJob).to(receive(:set).with(fifteen_minute_reminder_hash).and_return(double('scope').tap do |scope|
            # rubocop:enable RSpec/MessageSpies
            # rubocop:enable RSpec/StubbedMock
            # rubocop:enable RSpec/VerifiedDoubles
            # rubocop:todo RSpec/MessageSpies
            expect(scope).to(receive(:perform_later).with(individual_device, fifteen_minute_message))
            # rubocop:enable RSpec/MessageSpies
          end))
          subject # rubocop:todo RSpec/NamedSubject
        end
      end

      context 'when only expert has notifications on' do
        before { individual_user.update(allow_notifications: false) }

        it_behaves_like 'notification job with setter have been called n times', 1

        it 'notification job with proper arguments' do
          # rubocop:todo RSpec/VerifiedDoubles
          # rubocop:todo RSpec/StubbedMock
          # rubocop:todo RSpec/MessageSpies
          expect(PushNotification::SenderJob).to(receive(:set).with(fifteen_minute_reminder_hash).and_return(double('scope').tap do |scope|
            # rubocop:enable RSpec/MessageSpies
            # rubocop:enable RSpec/StubbedMock
            # rubocop:enable RSpec/VerifiedDoubles
            # rubocop:todo RSpec/MessageSpies
            expect(scope).to(receive(:perform_later).with(expert_device, fifteen_minute_message))
            # rubocop:enable RSpec/MessageSpies
          end))
          subject # rubocop:todo RSpec/NamedSubject
        end
      end
    end

    describe 'No reminder is in range to send notifications' do
      before do
        # current time of test will be 10 minutes before expert_call take place
        Timecop.freeze(10.minutes.ago(event_datetime))
      end

      after { Timecop.return }

      context 'with both expert and individual notifications on' do
        it_behaves_like 'notification job have not been called'
      end
    end
  end
end
