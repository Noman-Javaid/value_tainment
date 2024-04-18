require 'rails_helper'

describe Interactions::DeletionHelper do
  RSpec.shared_examples_for 'destroys all interactions' do
    it { expect(interactions).not_to include(be_persisted) }
  end

  RSpec.shared_examples_for 'destroys all interactions and notify' do
    it 'calls the notifier sender service' do
      interactions.each do |interaction|
        expect(Interactions::DeletionEventNotificationSender).to(
          have_received(:call).with(interaction, as_individual).exactly(1)
        )
      end
    end

    it_behaves_like 'destroys all interactions'
  end

  RSpec.shared_examples_for 'follow up tracker service is called' do
    it do
      expect(AccountDeletionFollowUps::TrackerHelper).to(
        have_received(:call).with(any_args).exactly(interactions.count)
      )
    end
  end

  RSpec.shared_examples_for 'destroys all interactions but do not notify' do
    it_behaves_like 'service not called', Interactions::DeletionEventNotificationSender, :call

    it_behaves_like 'destroys all interactions'
  end

  RSpec.shared_examples_for 'do not destroys interactions and do not notify' do
    it_behaves_like 'service not called', Interactions::DeletionEventNotificationSender, :call

    it 'not destroys all interactions' do
      expect(interactions).to all(be_persisted)
    end
  end

  RSpec.shared_context 'deletion helper service acts as expected' do # rubocop:todo RSpec/ContextWording
    describe '#call' do
      context 'when there is no deletion error' do
        before do
          allow(Interactions::DeletionEventNotificationSender).to(
            receive(:call).with(any_args).and_return(true)
          )
          deletion_service.call
        end

        context 'when interactions is nil' do
          let(:interactions) { nil }

          it_behaves_like 'service not called', Interactions::DeletionEventNotificationSender, :call
        end

        context 'when interactions is not nil' do
          context 'with an empty array' do
            let(:interactions) { [] }

            it_behaves_like 'service not called', Interactions::DeletionEventNotificationSender, :call
          end

          context 'with a list of pending quick questions' do
            let(:interactions) { create_list(:quick_question, 2) }

            it_behaves_like 'destroys all interactions and notify'
          end

          context 'with a list of draft_answered quick questions' do
            let(:interactions) { create_list(:quick_question, 2, :draft_answered) }

            it_behaves_like 'destroys all interactions and notify'
          end

          context 'with a list of expired quick questions' do
            let(:interactions) { create_list(:quick_question, 2, :expired) }

            it_behaves_like 'destroys all interactions but do not notify'
          end

          context 'with a list of failed quick questions' do
            let(:interactions) { create_list(:quick_question, 2, :failed) }

            it_behaves_like 'destroys all interactions but do not notify'
          end

          context 'with a list of answered quick questions' do
            let(:interactions) { create_list(:quick_question, 2, :answered) }

            it_behaves_like 'do not destroys interactions and do not notify'
          end

          context 'with a list of denied_complaint quick questions' do
            let(:interactions) { create_list(:quick_question, 2, :denied_complaint) }

            it_behaves_like 'do not destroys interactions and do not notify'
          end

          context 'with a list of filed_complaint quick questions' do
            let(:interactions) { create_list(:quick_question, 2, :filed_complaint) }

            it_behaves_like 'do not destroys interactions and do not notify'
          end

          context 'with a list of approved_complaint quick questions' do
            let(:interactions) { create_list(:quick_question, 2, :approved_complaint) }

            it_behaves_like 'do not destroys interactions and do not notify'
          end

          context 'with a list of transfered, quick questions' do
            let(:interactions) { create_list(:quick_question, 2, :transfered) }

            it_behaves_like 'do not destroys interactions and do not notify'
          end

          context 'with a list of refunded quick questions' do
            let(:interactions) { create_list(:quick_question, 2, :refunded) }

            it_behaves_like 'do not destroys interactions and do not notify'
          end

          context 'with a list of untransferred quick questions' do
            let(:interactions) { create_list(:quick_question, 2, :untransferred) }

            it_behaves_like 'do not destroys interactions and do not notify'
          end

          context 'with a list of requires_confirmation expert calls' do
            let(:interactions) { create_list(:expert_call, 2) }

            it_behaves_like 'destroys all interactions and notify'
          end

          context 'with a list of requires_reschedule_confirmation expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :requires_reschedule_confirmation) }

            it_behaves_like 'destroys all interactions and notify'
          end

          context 'with a list of scheduled expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :scheduled) }

            it_behaves_like 'destroys all interactions and notify'
          end

          context 'with a list of expired expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :expired) }

            it_behaves_like 'destroys all interactions but do not notify'
          end

          context 'with a list of failed expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :failed) }

            it_behaves_like 'destroys all interactions but do not notify'
          end

          context 'with a list of declined expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :declined) }

            it_behaves_like 'destroys all interactions but do not notify'
          end

          context 'with a list of incompleted expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :incompleted) }

            it_behaves_like 'destroys all interactions but do not notify'
          end

          context 'with a list of ongoing expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :ongoing) }

            it_behaves_like 'do not destroys interactions and do not notify'
          end

          context 'with a list of finished expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :finished) }

            it_behaves_like 'do not destroys interactions and do not notify'
          end

          context 'with a list of denied_complaint expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :denied_complaint) }

            it_behaves_like 'do not destroys interactions and do not notify'
          end

          context 'with a list of filed_complaint expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :filed_complaint) }

            it_behaves_like 'do not destroys interactions and do not notify'
          end

          context 'with a list of approved_complaint expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :approved_complaint) }

            it_behaves_like 'do not destroys interactions and do not notify'
          end

          context 'with a list of transfered expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :transfered) }

            it_behaves_like 'do not destroys interactions and do not notify'
          end

          context 'with a list of refunded expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :refunded) }

            it_behaves_like 'do not destroys interactions and do not notify'
          end

          context 'with a list of untransferred expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :untransferred) }

            it_behaves_like 'do not destroys interactions and do not notify'
          end
        end
      end

      context 'when there is a deletion error' do
        before do
          allow_any_instance_of(QuickQuestion).to( # rubocop:todo RSpec/AnyInstance
            receive(:destroy!).and_raise(StandardError, 'Test Error')
          )
          allow(AccountDeletionFollowUps::TrackerHelper).to(
            receive(:call).with(any_args).and_return(true)
          )
          deletion_service.call
        end

        context 'with a list of pending quick questions' do
          let(:interactions) { create_list(:quick_question, 2) }

          it_behaves_like 'follow up tracker service is called'
        end
      end
    end
  end

  let(:deletion_service) { described_class.new(interactions, as_individual) }

  # TODO- Update account deletion flow
  xdescribe 'service initialize as_individual with value true' do
    let(:as_individual) { true }

    it_behaves_like 'deletion helper service acts as expected'
  end

  xdescribe 'service initialize as_individual with value false' do
    let(:as_individual) { false }

    it_behaves_like 'deletion helper service acts as expected'
  end

  xdescribe '.call' do
    subject { described_class.call(interactions, as_individual) }

    let(:service) { double('deletion_helper_service') } # rubocop:todo RSpec/VerifiedDoubles
    let(:interactions) { nil }
    let(:as_individual) { false }

    it_behaves_like 'class service called'
  end
end
