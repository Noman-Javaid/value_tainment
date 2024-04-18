require 'rails_helper'

describe Stripes::ExpressAccounts::DeletionHandler do
  subject { deletion_handler_service.call }

  RSpec.shared_examples_for 'stripe account deletion service' do
    it 'is called' do
      subject
      expect(Stripe::Account).to(have_received(:delete).with(account_id).exactly(1))
    end
  end

  let(:deletion_handler_service) { described_class.new(expert) }
  let(:account_id) { expert.stripe_account_id }

  describe '#call' do
    context 'when expert is nil' do
      include_context 'with stripe mocks and stubs for account deletion unsuccess'

      let(:expert) { nil }
      let(:account_id) { nil }

      before { subject } # rubocop:todo RSpec/NamedSubject

      it_behaves_like 'service not called', Stripe::Account, :delete
    end

    context 'when expert is not nil' do
      context 'with no stripe_account_id' do
        let(:expert) { create(:expert) }

        it 'raises an argument error' do
          expect { deletion_handler_service }.to raise_error(ArgumentError)
        end
      end

      context 'with stripe_account_id' do
        let(:expert) { create(:expert, :with_profile) }

        context 'when retrieve the account delete object with success deletion' do
          include_context 'with stripe mocks and stubs for account deletion success'

          it_behaves_like 'stripe account deletion service'

          it 'returns true' do
            expect(subject).to eq(true) # rubocop:todo RSpec/NamedSubject
          end

          it 'changes the expert attribute ready_for_deletion to true' do
            subject # rubocop:todo RSpec/NamedSubject
            expect(expert).to be_ready_for_deletion
          end
        end

        context 'when retrieve the account delete object with unsuccess deletion' do
          include_context 'with stripe mocks and stubs for account deletion unsuccess'

          it_behaves_like 'stripe account deletion service'

          it 'returns true' do
            expect(subject).to eq(true) # rubocop:todo RSpec/NamedSubject
          end

          it 'do not changes the expert attribute ready_for_deletion to true' do
            subject # rubocop:todo RSpec/NamedSubject
            expect(expert).not_to be_ready_for_deletion
          end
        end

        context 'when retrieve service had an stripe error' do
          context 'with stripe error' do
            include_context 'with stripe mocks and stubs for account deletion with stripe error response'

            it_behaves_like 'stripe account deletion service'

            it 'returns nil' do
              expect(subject).to eq(nil) # rubocop:todo RSpec/NamedSubject
            end
          end

          context 'with rate limit error' do
            include_context 'with stripe mocks and stubs for account deletion with rate limit error'

            it_behaves_like 'stripe account deletion service'

            it 'returns nil' do
              expect(subject).to eq(nil) # rubocop:todo RSpec/NamedSubject
            end
          end
        end
      end
    end
  end

  describe '.call' do
    subject { described_class.call(expert) }

    let(:service) { double('deattach_service') } # rubocop:todo RSpec/VerifiedDoubles
    let(:expert) { nil }

    it_behaves_like 'class service called'
  end
end
