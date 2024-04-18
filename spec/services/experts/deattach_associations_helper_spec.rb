require 'rails_helper'

describe Experts::DeattachAssociationsHelper do
  subject { deattach_service.call }

  RSpec.shared_examples 'proper deattach results' do
    it 'has related associations count' do
      expect(expert.send(association_type).count).to eq(associations.count)
    end

    it 'returns true' do
      expect(subject).to be_truthy
    end

    it 'changes the expert user in associations for the default user' do
      subject
      expect(default_user.send(association_type).count).to eq(associations.count)
    end

    it 'resets expert user associations' do
      subject
      expect(expert.send(association_type).count).to eq(0)
    end
  end

  RSpec.shared_examples_for 'follow up tracker service is called' do
    it do
      expect(AccountDeletionFollowUps::TrackerHelper).to(
        have_received(:call).with(any_args).exactly(associations.count)
      )
    end
  end

  let(:deattach_service) { described_class.new(expert, association_type) }
  let(:expert) { create(:expert, :with_profile) }
  let(:default_user) { create(:user, :default).expert }
  let(:association_type) { nil }
  let(:associations) { nil }

  before do
    associations
    default_user
  end

  # TODO- Update account deletion flow
  xdescribe '#call' do
    context 'when expert is nil' do
      let(:expert) { nil }
      let(:default_user) { nil }

      it 'returns true when service is called' do
        expect(subject).to be_truthy # rubocop:todo RSpec/NamedSubject
      end
    end

    context 'when expert is not nil' do
      context 'when there is no default_user as expert' do
        let(:default_user) { nil }

        it 'returns false when service is called' do
          expect(subject).to be_falsey # rubocop:todo RSpec/NamedSubject
        end
      end

      context 'when there is a default_user as expert' do
        context 'with no associations related to the expert' do
          let(:association_type) { :transactions }
          let(:associations) { [] }

          it 'returns true when service is called' do
            expect(subject).to be_truthy # rubocop:todo RSpec/NamedSubject
          end
        end

        context 'with associations related to the expert' do
          context 'with transactions' do
            let(:association_type) { :transactions }
            let(:associations) do
              create_list(:transaction, 2, expert: expert)
            end

            it_behaves_like 'proper deattach results'
          end

          context 'with complaints' do
            let(:association_type) { :complaints }
            let(:associations) do
              create_list(:complaint, 2, :with_question_interaction, expert: expert)
            end

            it_behaves_like 'proper deattach results'
          end

          context 'with expert_calls' do
            let(:association_type) { :expert_calls }
            let(:associations) do
              create_list(:expert_call, 2, :transfered, expert: expert)
            end

            it_behaves_like 'proper deattach results'
          end

          context 'with quick_questions' do
            let(:association_type) { :quick_questions }
            let(:associations) do
              create_list(:quick_question, 2, :transfered, expert: expert)
            end

            it_behaves_like 'proper deattach results'
          end
        end

        context 'when can not deattach user in an association due to an error' do
          context 'with expert_calls' do
            let(:association_type) { :expert_calls }
            let(:associations) do
              create_list(:expert_call, 2, :transfered, expert: expert)
            end

            before do
              allow_any_instance_of(ExpertCall).to( # rubocop:todo RSpec/AnyInstance
                receive(:update!).and_raise(StandardError, 'Test Error')
              )
              allow(AccountDeletionFollowUps::TrackerHelper).to(
                receive(:call).with(any_args).and_return(true)
              )
              subject # rubocop:todo RSpec/NamedSubject
            end

            it_behaves_like 'follow up tracker service is called'
          end
        end
      end
    end
  end

  describe '.call' do
    subject { described_class.call(expert, association_type) }

    let(:service) { double('deattach_service') } # rubocop:todo RSpec/VerifiedDoubles
    let(:expert) { nil }
    let(:association_type) { nil }

    it_behaves_like 'class service called'
  end
end
