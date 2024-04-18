require 'rails_helper'

describe Interactions::DeletionEventNotificationSender do
  subject { sender_service.call }

  RSpec.shared_examples_for 'notifier service' do
    it 'is created' do
      expect(Notifications::DeletedEventNotifier).to(
        have_received(:new).with(message, users).exactly(1)
      )
    end

    it 'is called' do
      expect(notifier_service).to(have_received(:execute).with(no_args).exactly(1))
    end
  end

  RSpec.shared_context 'when notification sender service acts as expected' do
    describe '#call' do
      context 'when the interaction is nil' do
        let(:interaction) { nil }
        let(:message) { nil }
        let(:users) { nil }

        before { subject } # rubocop:todo RSpec/NamedSubject

        it_behaves_like 'service not called', Notifications::DeletedEventNotifier, :new
      end

      context 'when the interaction is not nil' do
        context 'when is persisted' do
          let(:message) { nil }
          let(:users) { nil }

          before { subject } # rubocop:todo RSpec/NamedSubject

          context 'with a quick question' do
            let(:interaction) { create(:quick_question) }

            it_behaves_like 'service not called', Notifications::DeletedEventNotifier, :new
          end

          context 'with an expert call' do
            let(:interaction) { create(:expert_call) }

            it_behaves_like 'service not called', Notifications::DeletedEventNotifier, :new
          end
        end

        context 'when is not persisted' do
          before do
            interaction.destroy
            subject # rubocop:todo RSpec/NamedSubject
          end

          context 'with a quick question' do
            let(:interaction) { create(:quick_question) }
            let(:users) { [main_user_to_send_notification] }

            it_behaves_like 'notifier service'
          end

          context 'with an expert call' do
            context 'with call_type 1-1' do
              let(:interaction) { create(:expert_call) }
              let(:users) { [main_user_to_send_notification] }

              it_behaves_like 'notifier service'
            end

            context 'with call_type 1-5' do
              let(:interaction) { create(:expert_call, :with_1to5) }
              let(:guest_users) { interaction.guests.map(&:user) }
              let(:users) { [main_user_to_send_notification] + guest_users }

              it_behaves_like 'notifier service'
            end
          end
        end
      end
    end
  end

  let(:sender_service) { described_class.new(interaction, as_individual) }
  let(:notifier_service) { double('notifier_service') } # rubocop:todo RSpec/VerifiedDoubles
  let(:interaction_type) { interaction.class.to_s.underscore.titleize }
  let(:interaction_subject) do
    interaction.respond_to?(:question) ? interaction.question.truncate(100) : interaction.title.truncate(100)
  end
  let(:message) do
    "The pending #{interaction_type} \"#{interaction_subject}\" has been deleted "\
    "because the #{user_role} User has deleted the account"
  end

  before do
    allow(Notifications::DeletedEventNotifier).to(
      receive(:new).with(message, users).and_return(notifier_service)
    )
    allow(notifier_service).to(receive(:execute).and_return(true))
  end

  # TODO- Update account deletion flow
  xdescribe 'service initialize as_individual with value true' do
    let(:as_individual) { true }
    let(:user_role) { 'Individual' }
    let(:main_user_to_send_notification) { interaction.expert.user }

    it_behaves_like 'when notification sender service acts as expected'
  end

  xdescribe 'service initialize as_individual with value false' do
    let(:as_individual) { false }
    let(:user_role) { 'Expert' }
    let(:main_user_to_send_notification) { interaction.individual.user }

    it_behaves_like 'when notification sender service acts as expected'
  end

  xdescribe '.call' do
    subject { described_class.call(interaction, as_individual) }

    let(:service) { double('notification_sender_service') } # rubocop:todo RSpec/VerifiedDoubles
    let(:interaction) { nil }
    let(:as_individual) { false }
    let(:message) { nil }
    let(:users) { nil }

    it_behaves_like 'class service called'
  end
end
