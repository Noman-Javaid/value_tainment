require 'rails_helper'

RSpec.describe Users::DeleteAccountsJob, type: :job do
  let(:users) { create_list(:user, 3, pending_to_delete: true) }

  before do
    allow(Users::AccountDeletionJob).to receive(:perform_later).and_return(nil)
    users
  end

  describe '#perform_later' do
    it 'enques the job' do
      expect { described_class.perform_later }.to enqueue_job
    end
  end

  describe '#perform_now' do
    it 'calls the account deletion job' do
      described_class.perform_now
      expect(Users::AccountDeletionJob).to(
        have_received(:perform_later).with(any_args).exactly(users.count)
      )
    end
  end
end
