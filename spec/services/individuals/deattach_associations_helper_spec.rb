require 'rails_helper'

describe Individuals::DeattachAssociationsHelper do
  subject { deattach_service.call }

  RSpec.shared_examples 'proper deattach results' do
    it 'has related associations count' do
      expect(individual.send(association_type).count).to eq(associations.count)
    end

    it 'returns true' do
      expect(subject).to be_truthy
    end

    it 'changes the individual user in associations for the default user' do
      subject
      expect(default_user.send(association_type).count).to eq(associations.count)
    end

    it 'resets individual user associations' do
      subject
      expect(individual.send(association_type).count).to eq(0)
    end
  end

  RSpec.shared_examples_for 'follow up tracker service is called' do
    it do
      expect(AccountDeletionFollowUps::TrackerHelper).to(
        have_received(:call).with(any_args).exactly(associations.count)
      )
    end
  end

  let(:deattach_service) { described_class.new(individual, association_type) }
  let(:individual) { create(:individual, :with_profile) }
  let(:default_user) { create(:user, :default).individual }
  let(:association_type) { nil }
  let(:associations) { nil }

  before do
    associations
    default_user
  end

  # TODO- Update account deletion flow
  xdescribe '#call' do
    context 'when individual is nil' do
      let(:individual) { nil }
      let(:default_user) { nil }

      it 'returns true when service is called' do
        expect(subject).to be_truthy # rubocop:todo RSpec/NamedSubject
      end
    end

    context 'when individual is not nil' do
      context 'when there is no default_user as individual' do
        let(:default_user) { nil }

        it 'returns false when service is called' do
          expect(subject).to be_falsey # rubocop:todo RSpec/NamedSubject
        end
      end

      context 'when there is a default_user as individual' do
        context 'with no associations related to the individual' do
          let(:association_type) { :transactions }
          let(:associations) { [] }

          it 'returns true when service is called' do
            expect(subject).to be_truthy # rubocop:todo RSpec/NamedSubject
          end
        end

        context 'with associations related to the individual' do
          context 'with transactions' do
            let(:association_type) { :transactions }
            let(:associations) do
              create_list(:transaction, 2, individual: individual)
            end

            it_behaves_like 'proper deattach results'
          end

          context 'with complaints' do
            let(:association_type) { :complaints }
            let(:associations) do
              create_list(:complaint, 2, :with_question_interaction, individual: individual)
            end

            it_behaves_like 'proper deattach results'
          end

          context 'with expert_calls' do
            let(:association_type) { :expert_calls }
            let(:associations) do
              create_list(:expert_call, 2, :transfered, individual: individual)
            end

            it_behaves_like 'proper deattach results'
          end

          context 'with guest_in_calls' do
            let(:association_type) { :guest_in_calls }
            let(:associations) do
              create_list(:guest_in_call, 2, individual: individual)
            end

            it_behaves_like 'proper deattach results'
          end

          context 'with quick_questions' do
            let(:association_type) { :quick_questions }
            let(:associations) do
              create_list(:quick_question, 2, :transfered, individual: individual)
            end

            it_behaves_like 'proper deattach results'
          end
        end

        context 'when can not deattach user in an association due to an error' do
          context 'with expert_calls' do
            let(:association_type) { :expert_calls }
            let(:associations) do
              create_list(:expert_call, 2, :transfered, individual: individual)
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
    subject { described_class.call(individual, association_type) }

    let(:service) { double('deattach_service') } # rubocop:todo RSpec/VerifiedDoubles
    let(:individual) { nil }
    let(:association_type) { nil }

    it_behaves_like 'class service called'
  end
end
