require 'rails_helper'

describe Experts::Accounts::DeletionSetUp do
  subject { deletion_service.call }

  RSpec.shared_examples_for 'quick questions deattach' do
    it 'changes the expert user in associations for the default user' do
      subject
      expect(default_user.quick_questions.count).to eq(quick_questions.count)
    end

    it 'has no questions associated with the expert user' do
      subject
      expect(expert.quick_questions.count).to eq(0)
    end
  end

  RSpec.shared_examples_for 'expert calls deattach' do
    it 'changes the expert user in associations for the default user' do
      subject
      expect(default_user.expert_calls.count).to eq(expert_calls.count)
    end

    it 'has no questions associated with the expert user' do
      subject
      expect(expert.expert_calls.count).to eq(0)
    end
  end

  let(:deletion_service) { described_class.new(expert) }

  # TODO- Update account deletion flow
  xdescribe '#call' do
    context 'when expert is nil returns true' do
      let(:expert) { nil }

      it { expect(subject).to be_truthy } # rubocop:todo RSpec/NamedSubject
    end

    context 'when expert is not nil' do
      let(:inactive_user) { create(:user) }
      let(:expert) { create(:expert, :with_profile, user: inactive_user) }

      context 'with default_user in db' do
        let(:default_user) { create(:user, :default).expert }

        before { default_user }

        context 'when expert has no stripe_account_id' do
          let(:expert) { create(:expert, user: inactive_user) }

          it { expect(subject).to be_truthy } # rubocop:todo RSpec/NamedSubject
        end

        context 'when expert has pending for completion interactions' do
          include_context 'with stripe mocks and stubs for balance retriever with no pending payouts'

          context 'with pending questions to answer' do
            let(:quick_questions) do
              create_list(:quick_question, 2, expert: expert)
            end

            before do
              quick_questions
              inactive_user.update!(active: false)
            end

            it { expect(subject).to be_truthy } # rubocop:todo RSpec/NamedSubject

            it 'has no quick_questions related to the default user' do
              subject # rubocop:todo RSpec/NamedSubject
              expect(default_user.quick_questions.count).to eq(0)
            end

            it 'has no quick_questions related to the expert user' do
              subject # rubocop:todo RSpec/NamedSubject
              expect(expert.quick_questions.count).to eq(0)
            end
          end

          context 'with pending calls to schedule' do
            let(:expert_calls) do
              create_list(:expert_call, 2, expert: expert)
            end

            before do
              expert_calls
              inactive_user.update!(active: false)
            end

            it { expect(subject).to be_truthy } # rubocop:todo RSpec/NamedSubject

            it 'has no expert_calls related to the default user' do
              subject # rubocop:todo RSpec/NamedSubject
              expect(default_user.expert_calls.count).to eq(0)
            end

            it 'has no expert_calls related to the expert user' do
              subject # rubocop:todo RSpec/NamedSubject
              expect(expert.expert_calls.count).to eq(0)
            end
          end
        end

        context 'when expert has pending for payment interactions' do
          include_context 'with stripe mocks and stubs for successfull payment confirmation'
          include_context 'with stripe mocks and stubs for balance retriever with pending payouts'

          context 'with answered questions' do
            let(:quick_questions) do
              create_list(:quick_question, 2, :answered, expert: expert)
            end

            before do
              quick_questions
              inactive_user.update!(active: false)
            end

            it { expect(subject).to be_falsey } # rubocop:todo RSpec/NamedSubject

            it 'has questions associated with the expert user' do
              subject # rubocop:todo RSpec/NamedSubject
              expect(expert.quick_questions.count).to eq(quick_questions.count)
            end
          end

          context 'with finished calls' do
            include_context 'with stripe mocks and stubs for balance retriever with pending payouts'
            include_context 'with stripe mocks and stubs for balance retriever with pending payouts'

            let(:expert_calls) do
              create_list(:expert_call, 2, :finished, expert: expert)
            end

            before do
              expert_calls
              inactive_user.update!(active: false)
            end

            it { expect(subject).to be_falsey } # rubocop:todo RSpec/NamedSubject

            it 'has calls associated with the expert user' do
              subject # rubocop:todo RSpec/NamedSubject
              expect(expert.expert_calls.count).to eq(expert_calls.count)
            end
          end

          context 'with ongoing calls where the expert joined the call' do
            include_context 'with stripe mocks and stubs for balance retriever with no pending payouts'
            include_context 'with Twilio mocks and stubs to close call'

            let(:expert_calls) do
              create_list(:expert_call, 1, :ongoing_with_expert_participant_event, expert: expert)
            end

            before do
              expert_calls
              inactive_user.update!(active: false)
            end

            it { expect(subject).to be_truthy } # rubocop:todo RSpec/NamedSubject

            it 'has no calls associated with the expert user' do
              subject # rubocop:todo RSpec/NamedSubject
              expect(expert.expert_calls.count).to eq(0)
            end
          end

          context 'with ongoing calls where the expert did not joined the call' do
            include_context 'with Twilio mocks and stubs to close call'
            include_context 'with stripe mocks and stubs for balance retriever with no pending payouts'

            let(:expert_calls) do
              create_list(:expert_call, 1, :ongoing, expert: expert)
            end

            before do
              expert_calls
              inactive_user.update!(active: false)
            end

            it { expect(subject).to be_truthy } # rubocop:todo RSpec/NamedSubject

            it 'has no interaction related to the default user' do
              subject # rubocop:todo RSpec/NamedSubject
              expect(default_user.expert_calls.count).to eq(0)
            end
          end
        end

        context 'when expert has interactions with completed transactions' do
          include_context 'with stripe mocks and stubs for balance retriever with no pending payouts'

          context 'with transfered questions' do
            let(:quick_questions) do
              create_list(:quick_question, 2, :transfered, expert: expert)
            end

            before do
              quick_questions
              inactive_user.update!(active: false)
            end

            it { expect(subject).to be_truthy } # rubocop:todo RSpec/NamedSubject

            it_behaves_like 'quick questions deattach'
          end

          context 'with transfered calls' do
            let(:expert_calls) do
              create_list(:expert_call, 2, :transfered, expert: expert)
            end

            before do
              expert_calls
              inactive_user.update!(active: false)
            end

            it { expect(subject).to be_truthy } # rubocop:todo RSpec/NamedSubject

            it_behaves_like 'expert calls deattach'
          end
        end

        context 'when expert has interactions with pending transactions' do
          include_context 'with stripe mocks and stubs for balance retriever with pending payouts'

          context 'with transfered questions' do
            let(:quick_questions) do
              create_list(:quick_question, 2, :transfered, expert: expert)
            end

            before do
              quick_questions
              inactive_user.update!(active: false)
            end

            it { expect(subject).to be_falsey } # rubocop:todo RSpec/NamedSubject

            it 'has calls associated with the expert user' do
              subject # rubocop:todo RSpec/NamedSubject
              expect(expert.quick_questions.count).to eq(quick_questions.count)
            end
          end

          context 'with transfered calls' do
            let(:expert_calls) do
              create_list(:expert_call, 2, :transfered, expert: expert)
            end

            before do
              expert_calls
              inactive_user.update!(active: false)
            end

            it { expect(subject).to be_falsey } # rubocop:todo RSpec/NamedSubject

            it 'has calls associated with the expert user' do
              subject # rubocop:todo RSpec/NamedSubject
              expect(expert.expert_calls.count).to eq(expert_calls.count)
            end
          end
        end
      end

      context 'with no default_user in db' do
        context 'when expert has no related interactions returns false' do
          include_context 'with stripe mocks and stubs for balance retriever with no pending payouts'

          it { expect(subject).to be_falsey } # rubocop:todo RSpec/NamedSubject
        end
      end
    end
  end

  describe '.call' do
    subject { described_class.call(expert) }

    let(:service) { double('set_up_service') } # rubocop:todo RSpec/VerifiedDoubles
    let(:expert) { nil }

    it_behaves_like 'class service called'
  end
end
