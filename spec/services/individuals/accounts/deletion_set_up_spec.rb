require 'rails_helper'

describe Individuals::Accounts::DeletionSetUp do
  subject { deletion_service.call }

  RSpec.shared_examples_for 'quick questions deattach' do
    it 'changes the individual user in associations for the default user' do
      subject
      expect(default_user.quick_questions.count).to eq(quick_questions.count)
    end

    it 'has no questions associated with the individual user' do
      subject
      expect(individual.quick_questions.count).to eq(0)
    end
  end

  RSpec.shared_examples_for 'expert calls deattach' do
    it 'changes the individual user in associations for the default user' do
      subject
      expect(default_user.expert_calls.count).to eq(expert_calls.count)
    end

    it 'has no questions associated with the individual user' do
      subject
      expect(individual.expert_calls.count).to eq(0)
    end
  end

  let(:deletion_service) { described_class.new(individual) }

  # TODO- Update account deletion flow
  xdescribe '#call' do
    context 'when individual is nil returns true' do
      let(:individual) { nil }

      it { expect(subject).to be_truthy } # rubocop:todo RSpec/NamedSubject
    end

    context 'when individual is not nil' do
      let(:inactive_user) { create(:user, active: false) }
      let(:individual) { create(:individual, :with_profile, user: inactive_user) }

      context 'with default_user in db' do
        let(:default_user) { create(:user, :default).individual }

        before { default_user }

        context 'when individual has no related interactions returns true' do
          it { expect(subject).to be_truthy } # rubocop:todo RSpec/NamedSubject
        end

        context 'when individual has pending for completion interactions' do
          context 'with pending questions to answer' do
            let(:quick_questions) do
              create_list(:quick_question, 2, individual: individual)
            end

            before { quick_questions }

            it { expect(subject).to be_truthy } # rubocop:todo RSpec/NamedSubject

            it 'has no interaction related to the default user' do
              subject # rubocop:todo RSpec/NamedSubject
              expect(default_user.quick_questions.count).to eq(0)
            end
          end

          context 'with pending calls to schedule' do
            let(:expert_calls) do
              create_list(:expert_call, 2, individual: individual)
            end

            before { expert_calls }

            it { expect(subject).to be_truthy } # rubocop:todo RSpec/NamedSubject

            it 'has no interaction related to the default user' do
              subject # rubocop:todo RSpec/NamedSubject
              expect(default_user.expert_calls.count).to eq(0)
            end
          end
        end

        context 'when individual has pending for payment interactions' do
          include_context 'with stripe mocks and stubs for successfull payment confirmation'

          context 'with answered questions' do
            let(:quick_questions) do
              create_list(:quick_question, 2, :answered, individual: individual)
            end

            before { quick_questions }

            it { expect(subject).to be_truthy } # rubocop:todo RSpec/NamedSubject

            it_behaves_like 'quick questions deattach'
          end

          context 'with finished calls' do
            let(:expert_calls) do
              create_list(:expert_call, 2, :finished, individual: individual)
            end

            before { expert_calls }

            it { expect(subject).to be_truthy } # rubocop:todo RSpec/NamedSubject

            it_behaves_like 'expert calls deattach'
          end

          context 'with ongoing calls where the expert joined the call' do
            include_context 'with Twilio mocks and stubs to close call'

            let(:expert_calls) do
              create_list(:expert_call, 1, :ongoing_with_expert_participant_event, individual: individual)
            end

            before { expert_calls }

            it { expect(subject).to be_truthy } # rubocop:todo RSpec/NamedSubject

            it_behaves_like 'expert calls deattach'
          end

          context 'with ongoing calls where the expert did not joined the call' do
            include_context 'with Twilio mocks and stubs to close call'

            let(:expert_calls) do
              create_list(:expert_call, 1, :ongoing, individual: individual)
            end

            before { expert_calls }

            it { expect(subject).to be_truthy } # rubocop:todo RSpec/NamedSubject

            it 'has no interaction related to the default user' do
              subject # rubocop:todo RSpec/NamedSubject
              expect(default_user.expert_calls.count).to eq(0)
            end
          end
        end

        context 'when individual has interactions with completed transactions' do
          context 'with transfered questions' do
            let(:quick_questions) do
              create_list(:quick_question, 2, :transfered, individual: individual)
            end

            before { quick_questions }

            it { expect(subject).to be_truthy } # rubocop:todo RSpec/NamedSubject

            it_behaves_like 'quick questions deattach'
          end

          context 'with transfered calls' do
            let(:expert_calls) do
              create_list(:expert_call, 2, :transfered, individual: individual)
            end

            before { expert_calls }

            it { expect(subject).to be_truthy } # rubocop:todo RSpec/NamedSubject

            it_behaves_like 'expert calls deattach'
          end
        end
      end

      context 'with no default_user in db' do
        context 'when individual has no related interactions returns true' do
          it { expect(subject).to be_falsey } # rubocop:todo RSpec/NamedSubject
        end
      end
    end
  end

  describe '.call' do
    subject { described_class.call(individual) }

    let(:service) { double('set_up_service') } # rubocop:todo RSpec/VerifiedDoubles
    let(:individual) { nil }

    it_behaves_like 'class service called'
  end
end
