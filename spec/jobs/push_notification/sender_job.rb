require 'rails_helper'

describe PushNotification::SenderJob do # rubocop:todo RSpec/FilePath
  let(:perform_later) { described_class.perform_later }
  let(:perform_now) { described_class.perform_now }
  let(:service) { instance_double('Mobile::OneSignal::NotificationPusher') }

  before do
    allow_any_instance_of(Mobile::OneSignal::NotificationPusher).to( # rubocop:todo RSpec/AnyInstance
      receive(:execute).and_return(true)
    )
  end

  it 'queues the job' do
    expect { perform_later }.to have_enqueued_job(described_class)
      .on_queue('notifications')
  end
end
