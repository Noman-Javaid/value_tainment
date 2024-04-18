require 'rails_helper'

describe Notifications::DeletedEventNotifier do
  subject { notifier_service.execute }

  let(:notifier_service) { described_class.new(message, users) }
  let(:message) { 'The event was removed' }
  let(:users) { nil }

  describe '#call' do
    context 'when message is nil' do
      let(:message) { nil }
      let(:users) { [create(:user)] }

      it_behaves_like 'notification job have not been called'
    end

    context 'when users is empty' do
      let(:users) { [] }

      it_behaves_like 'notification job have not been called'
    end

    context 'when users is not empty' do
      let(:users) { create_list(:user, 2, :with_profile) }

      context 'when users do not allow notifications' do
        before do
          users.each { |user| user.update(allow_notifications: false) }
        end

        it_behaves_like 'notification job have not been called'
      end

      context 'when users do allow notifications' do
        it_behaves_like 'notification job with perform_later have been called n times', 2
      end
    end
  end
end
