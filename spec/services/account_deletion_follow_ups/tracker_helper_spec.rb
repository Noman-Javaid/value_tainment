require 'rails_helper'

describe AccountDeletionFollowUps::TrackerHelper do
  subject { tracker_service.call }

  let(:tracker_service) { described_class.new(user, note) }

  describe '#call' do
    context 'when user is nil' do
      let(:user) { nil }
      let(:note) { nil }

      before { subject } # rubocop:todo RSpec/NamedSubject

      it 'service call returns nil' do
        expect(subject).to be_nil # rubocop:todo RSpec/NamedSubject
      end
    end

    context 'when user is not nil' do
      let(:note) { 'Test Note' }
      let(:user) { create(:user, :with_profile) }

      context 'without account deletion follow up' do
        before { subject } # rubocop:todo RSpec/NamedSubject

        it 'service call returns nil' do
          expect(subject).to be_nil # rubocop:todo RSpec/NamedSubject
        end
      end

      context 'with account deletion follow up' do
        context 'when note to add is already logged' do
          let(:follow_up) { create(:account_deletion_follow_up, user: user, notes: note) }

          before { follow_up }

          it 'does not change the current notes' do
            expect { subject }.not_to change(follow_up, :notes) # rubocop:todo RSpec/NamedSubject
          end
        end

        context 'when note to add is not logged' do
          let(:follow_up) { create(:account_deletion_follow_up, user: user) }

          before { follow_up }

          it 'changes the current notes' do
            expect { subject }.to change(follow_up, :notes) # rubocop:todo RSpec/NamedSubject
          end

          it 'has the note value' do
            subject # rubocop:todo RSpec/NamedSubject
            expect(follow_up.notes).to include(note)
          end
        end
      end
    end
  end

  describe '.call' do
    subject { described_class.call(user, note) }

    let(:service) { double('tracker_service') } # rubocop:todo RSpec/VerifiedDoubles
    let(:user) { nil }
    let(:note) { false }

    it_behaves_like 'class service called'
  end
end
