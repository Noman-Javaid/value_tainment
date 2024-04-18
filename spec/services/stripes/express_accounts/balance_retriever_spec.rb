require 'rails_helper'

describe Stripes::ExpressAccounts::BalanceRetriever do
  subject { balance_retriever_service.call }

  RSpec.shared_examples_for 'stripe balance retriever service' do
    it 'is called' do
      subject
      expect(Stripe::Balance).to(
        have_received(:retrieve).with({ stripe_account: account_id }).exactly(1)
      )
    end
  end

  RSpec.shared_examples_for 'returns the balance object' do
    it { expect(subject).to eq(balance) }
  end

  let(:balance_retriever_service) { described_class.new(expert) }
  let(:account_id) { expert.stripe_account_id }

  describe '#call' do
    context 'when expert is nil' do
      include_context 'with stripe mocks and stubs for balance retriever with no pending payouts'

      let(:expert) { nil }
      let(:account_id) { nil }

      before { subject } # rubocop:todo RSpec/NamedSubject

      it_behaves_like 'service not called', Stripe::Balance, :retrieve
    end

    context 'when expert is not nil' do
      context 'with no stripe_account_id' do
        let(:expert) { create(:expert) }

        it 'raises an argument error' do
          expect { balance_retriever_service }.to raise_error(ArgumentError)
        end
      end

      context 'with stripe_account_id' do
        let(:expert) { create(:expert, :with_profile) }

        context 'when retrieve the balance object' do
          context 'with no pending payouts' do
            include_context 'with stripe mocks and stubs for balance retriever with no pending payouts'

            it_behaves_like 'stripe balance retriever service'

            it_behaves_like 'returns the balance object'

            it 'has the sum amount of pending equal to zero' do
              expect(balance.pending.map(&:amount).sum).to be_zero
            end

            it 'has the sum amount of available equal to zero' do
              expect(balance.available.map(&:amount).sum).to be_zero
            end

            it 'has the sum amount of instant_available equal to zero' do
              expect(balance.instant_available.map(&:amount).sum).to be_zero
            end

            it 'has the sum amount of connect_reserved equal to zero' do
              expect(balance.connect_reserved.map(&:amount).sum).to be_zero
            end
          end

          # most common flow, since transfers from payment intents could take up to two
          # days to arrive to the connected account
          context 'with pending payouts' do
            include_context 'with stripe mocks and stubs for balance retriever with pending payouts'

            it_behaves_like 'stripe balance retriever service'

            it_behaves_like 'returns the balance object'

            it 'has the sum amount of pending greater than zero' do
              expect(balance.pending.map(&:amount).sum).to be_positive
            end
          end

          # uncommon flow, since payouts are scheduled to execute by default
          context 'with available payouts' do
            include_context 'with stripe mocks and stubs for balance retriever with available payouts'

            it_behaves_like 'stripe balance retriever service'

            it_behaves_like 'returns the balance object'

            it 'has the sum amount of available greater than zero' do
              expect(balance.available.map(&:amount).sum).to be_positive
            end
          end

          # uncommon flow, since instant_available (execution of payouts as soon as payment is
          # completed [this is a premium feature currently not implemented]) are not handled
          context 'with instance_available payouts' do
            include_context 'with stripe mocks and stubs for balance retriever with instant_available payouts'

            it_behaves_like 'stripe balance retriever service'

            it_behaves_like 'returns the balance object'

            it 'has the sum amount of instant_available greater than zero' do
              expect(balance.instant_available.map(&:amount).sum).to be_positive
            end
          end

          # uncommon flow, since connect_reserved (negative balances [not handling refunds])
          # are not handled
          context 'with connect_reserved payouts' do
            include_context 'with stripe mocks and stubs for balance retriever with connect_reserved payouts'

            it_behaves_like 'stripe balance retriever service'

            it_behaves_like 'returns the balance object'

            it 'has the sum amount of connect_reserved greater than zero' do
              expect(balance.connect_reserved.map(&:amount).sum).to be_positive
            end
          end
        end

        context 'when retrieve service had an stripe error' do
          context 'with stripe error' do
            include_context 'with stripe mocks and stubs for balance retriever with stripe error response'

            it_behaves_like 'stripe balance retriever service'

            it 'returns error object' do
              expect(subject).to respond_to(:error) # rubocop:todo RSpec/NamedSubject
            end
          end

          context 'with rate limit error' do
            include_context 'with stripe mocks and stubs for balance retriever with rate limit error'

            it_behaves_like 'stripe balance retriever service'

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

    let(:service) { double('balance_retriever_service') } # rubocop:todo RSpec/VerifiedDoubles
    let(:expert) { nil }

    it_behaves_like 'class service called'
  end
end
