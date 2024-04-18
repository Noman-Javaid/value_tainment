require 'rails_helper'

describe Users::AccountDeletion do
  subject { account_deletion_service.call }

  RSpec.shared_examples_for 'user deleted, follow up created and mail sent' do
    it 'deletes the user' do
      subject
      expect { User.find(user.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it { expect { subject }.to change(AccountDeletionFollowUp, :count).by(1) }

    it { expect { subject }.to change { ActionMailer::Base.deliveries.size }.by(1) }
  end

  let(:account_deletion_service) { described_class.new(user) }

  # TODO- Update account deletion flow
  xdescribe '#call' do
    let(:default_user) { create(:user, :default_with_both_profiles) }

    before { default_user }

    context 'when user is nil' do
      let(:user) { nil }

      before do
        allow(Individuals::Accounts::DeletionSetUp).to receive(:call).and_return(nil)
        allow(Experts::Accounts::DeletionSetUp).to receive(:call).and_return(nil)
        subject # rubocop:todo RSpec/NamedSubject
      end

      it_behaves_like 'service not called', Individuals::Accounts::DeletionSetUp, :call
      it_behaves_like 'service not called', Experts::Accounts::DeletionSetUp, :call
    end

    context 'when user is not nil' do
      include_context 'with stripe mocks and stubs for user account deletion service'

      context 'with individual profile' do
        include_context 'users_for_individual_endpoints'

        context 'when individual has no pending interactions' do
          let(:stripe_customer_id) { individual.stripe_customer_id }
          let(:account_deletion_follow_up) do
            AccountDeletionFollowUp.find_by!(stripe_customer_id: stripe_customer_id)
          end

          it_behaves_like 'user deleted, follow up created and mail sent'

          context 'when an account deletion follow up remains in db' do
            it 'is related to the deleted user stripe customer' do
              subject # rubocop:todo RSpec/NamedSubject
              expect { account_deletion_follow_up }.not_to raise_error
            end

            it 'has resolved status' do
              subject # rubocop:todo RSpec/NamedSubject
              expect(account_deletion_follow_up.status).to eq('resolved')
            end

            it 'has no related user' do
              subject # rubocop:todo RSpec/NamedSubject
              expect(account_deletion_follow_up.user).to be_nil
            end
          end
        end

        context 'when individual has pending interactions' do
          include_context 'with stripe mocks and stubs for payment intent confirmation with rate limit error'

          let(:quick_questions) do
            create_list(:quick_question, 2, :answered, individual: individual)
          end

          before do
            quick_questions
            subject # rubocop:todo RSpec/NamedSubject
          end

          it 'do not delete the user' do
            expect { User.find(user.id) }.not_to raise_error
          end

          it 'do not change the value for ready_for_deletion in the individual profile' do
            expect(user.individual).not_to be_ready_for_deletion
          end

          context 'when an account deletion follow up remains in db' do
            it 'has individual profile indicator to do the revision as true' do
              expect(user.account_deletion_follow_up.required_for_individual).to be_truthy
            end

            it 'has expert profile indicator to do the revision as false' do
              expect(user.account_deletion_follow_up.required_for_expert).to be_falsey
            end

            it 'is related to the user' do
              expect(user.account_deletion_follow_up).not_to be_nil
            end

            it 'has requires_revision status' do
              expect(user.account_deletion_follow_up.status).to eq('requires_revision')
            end
          end
        end
      end

      context 'with expert profile' do
        include_context 'users_for_expert_endpoints'

        context 'with no stripe account' do
          before { expert.update!(stripe_account_id: nil) }

          it_behaves_like 'user deleted, follow up created and mail sent'
        end

        context 'with a stripe account' do
          context 'when has no pending transactions in stripe' do
            include_context 'with stripe mocks and stubs for balance retriever with no pending payouts'

            let(:stripe_account_id) { expert.stripe_account_id }
            let(:account_deletion_follow_up) do
              AccountDeletionFollowUp.find_by!(stripe_account_id: stripe_account_id)
            end

            it_behaves_like 'user deleted, follow up created and mail sent'

            context 'when an account deletion follow up remains in db' do
              it 'is related to the deleted user stripe account' do
                subject # rubocop:todo RSpec/NamedSubject
                expect { account_deletion_follow_up }.not_to raise_error
              end

              it 'has resolved status' do
                subject # rubocop:todo RSpec/NamedSubject
                expect(account_deletion_follow_up.status).to eq('resolved')
              end

              it 'has no related user' do
                subject # rubocop:todo RSpec/NamedSubject
                expect(account_deletion_follow_up.user).to be_nil
              end
            end
          end

          context 'when has pending transactions in stripe' do
            include_context 'with stripe mocks and stubs for balance retriever with pending payouts'

            before { subject } # rubocop:todo RSpec/NamedSubject

            it 'do not delete the user' do
              expect { User.find(user.id) }.not_to raise_error
            end

            it 'do not change the value ready_for_deletion in the expert profile' do
              expect(user.expert).not_to be_ready_for_deletion
            end

            context 'when an account deletion follow up remains in db' do
              it 'has expert profile indicator to do the revision as true' do
                expect(user.account_deletion_follow_up.required_for_expert).to be_truthy
              end

              it 'has individual profile indicator to do the revision as false' do
                expect(user.account_deletion_follow_up.required_for_individual).to be_falsey
              end

              it 'is related to the user' do
                expect(user.account_deletion_follow_up).not_to be_nil
              end

              it 'has requires_revision status' do
                expect(user.account_deletion_follow_up.status).to eq('requires_revision')
              end
            end
          end
        end
      end

      context 'with both profiles' do
        include_context 'users_with_both_profiles'

        context 'when has no pending transactions' do
          include_context 'with stripe mocks and stubs for balance retriever with no pending payouts'

          it_behaves_like 'user deleted, follow up created and mail sent'
        end

        context 'when has pending interactions to resolve' do
          include_context 'with stripe mocks and stubs for balance retriever with no pending payouts'
          include_context 'with stripe mocks and stubs for payment intent confirmation with rate limit error'

          let(:individual_quick_questions) do
            create_list(:quick_question, 2, :answered, individual: user.individual)
          end

          let(:expert_quick_questions) do
            create_list(:quick_question, 2, :answered, expert: expert)
          end

          before do
            individual_quick_questions
            expert_quick_questions
            subject # rubocop:todo RSpec/NamedSubject
          end

          it 'do not delete the user' do
            expect { User.find(user.id) }.not_to raise_error
          end

          it 'do not change the value ready_for_deletion in the individual profile' do
            expect(user.individual).not_to be_ready_for_deletion
          end

          it 'do not change the value ready_for_deletion in the expert profile' do
            expect(user.expert).not_to be_ready_for_deletion
          end

          context 'when an account deletion follow up remains in db' do
            it 'has expert profile indicator to do the revision as true' do
              expect(user.account_deletion_follow_up.required_for_expert).to be_truthy
            end

            it 'has individual profile indicator to do the revision as true' do
              expect(user.account_deletion_follow_up.required_for_individual).to be_truthy
            end

            it 'is related to the user' do
              expect(user.account_deletion_follow_up).not_to be_nil
            end

            it 'has requires_revision status' do
              expect(user.account_deletion_follow_up.status).to eq('requires_revision')
            end
          end
        end
      end
    end
  end
end
