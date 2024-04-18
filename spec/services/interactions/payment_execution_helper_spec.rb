require 'rails_helper'

describe Interactions::PaymentExecutionHelper do
  def follow_up_note(interaction)
    "**In class #{described_class} with #{interaction.class} id: #{interaction.id} "\
    "as individual? -> #{as_individual}, Stripe error: #{stripe_error}"
  end

  RSpec.shared_examples_for 'payment services not called' do
    it_behaves_like 'service not called', Stripes::Payments::CancelationHandler, :call

    it_behaves_like 'service not called', Stripes::Payments::ConfirmationHandler, :call
  end

  RSpec.shared_examples_for 'follow up tracker service is called for each interaction' do
    it do
      interactions.each do |interaction|
        expect(AccountDeletionFollowUps::TrackerHelper).to(
          have_received(:call).with(user_profile, follow_up_note(interaction)).exactly(1)
        )
      end
    end
  end

  RSpec.shared_examples_for 'cancelation payment service is called' do
    it_behaves_like 'service not called', Stripes::Payments::ConfirmationHandler, :call

    it 'calls the cancelation payment service' do
      interactions.each do |interaction|
        expect(Stripes::Payments::CancelationHandler).to(
          have_received(:call).with(interaction).exactly(1)
        )
      end
    end
  end

  RSpec.shared_examples_for 'confirmation payment service is called' do
    it_behaves_like 'service not called', Stripes::Payments::CancelationHandler, :call

    it 'calls the confirmation payment service' do
      interactions.each do |interaction|
        expect(Stripes::Payments::ConfirmationHandler).to(
          have_received(:call).with(interaction).exactly(1)
        )
      end
    end
  end

  RSpec.shared_context 'when payment execution service acts as expected' do
    describe '#call' do
      subject { payment_execution_helper.call }

      let(:payment_execution_helper) { described_class.new(interactions, as_individual) }

      context 'with stripe mocks and success api call' do
        before do
          allow(Stripes::Payments::CancelationHandler).to(
            receive(:call).with(any_args).and_return(OpenStruct.new(status: 'canceled'))
          )
          allow(Stripes::Payments::ConfirmationHandler).to(
            receive(:call).with(any_args).and_return(OpenStruct.new(status: 'succeded'))
          )
          subject # rubocop:todo RSpec/NamedSubject
        end

        context 'when interactions is nil' do
          let(:interactions) { nil }

          it_behaves_like 'payment services not called'
        end

        context 'when interactions is not nil' do
          context 'with an empty array' do
            let(:interactions) { [] }

            it_behaves_like 'payment services not called'
          end

          context 'with a list of pending quick questions' do
            let(:interactions) { create_list(:quick_question, 2) }

            it_behaves_like 'payment services not called'
          end

          context 'with a list of draft_answered quick questions' do
            let(:interactions) { create_list(:quick_question, 2, :draft_answered, individual: individual, expert: expert) }

            it_behaves_like 'payment services not called'
          end

          context 'with a list of expired quick questions' do
            let(:interactions) { create_list(:quick_question, 2, :expired, individual: individual, expert: expert) }

            it_behaves_like 'payment services not called'
          end

          context 'with a list of failed quick questions' do
            let(:interactions) { create_list(:quick_question, 2, :failed, individual: individual, expert: expert) }

            it_behaves_like 'payment services not called'
          end

          context 'with a list of answered quick questions' do
            let(:interactions) { create_list(:quick_question, 2, :answered, individual: individual, expert: expert) }

            it_behaves_like 'confirmation payment service is called'
          end

          context 'with a list of denied_complaint quick questions' do
            let(:interactions) { create_list(:quick_question, 2, :denied_complaint, individual: individual, expert: expert) }

            it_behaves_like 'confirmation payment service is called'
          end

          context 'with a list of filed_complaint quick questions' do
            let(:interactions) { create_list(:quick_question, 2, :filed_complaint, individual: individual, expert: expert) }

            it_behaves_like 'confirmation payment service is called'
          end

          context 'with a list of approved_complaint quick questions' do
            let(:interactions) { create_list(:quick_question, 2, :approved_complaint, individual: individual, expert: expert) }

            it_behaves_like 'cancelation payment service is called'
          end

          context 'with a list of transfered, quick questions' do
            let(:interactions) { create_list(:quick_question, 2, :transfered, individual: individual, expert: expert) }

            it_behaves_like 'payment services not called'
          end

          context 'with a list of refunded quick questions' do
            let(:interactions) { create_list(:quick_question, 2, :refunded, individual: individual, expert: expert) }

            it_behaves_like 'payment services not called'
          end

          context 'with a list of untransferred quick questions' do
            let(:interactions) { create_list(:quick_question, 2, :untransferred, individual: individual, expert: expert) }

            it_behaves_like 'payment services not called'
          end

          context 'with a list of requires_confirmation expert calls' do
            let(:interactions) { create_list(:expert_call, 2, individual: individual, expert: expert) }

            it_behaves_like 'payment services not called'
          end

          context 'with a list of requires_reschedule_confirmation expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :requires_reschedule_confirmation, individual: individual, expert: expert) }

            it_behaves_like 'payment services not called'
          end

          context 'with a list of scheduled expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :scheduled, individual: individual, expert: expert) }

            it_behaves_like 'payment services not called'
          end

          context 'with a list of expired expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :expired, individual: individual, expert: expert) }

            it_behaves_like 'payment services not called'
          end

          context 'with a list of failed expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :failed, individual: individual, expert: expert) }

            it_behaves_like 'payment services not called'
          end

          context 'with a list of declined expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :declined, individual: individual, expert: expert) }

            it_behaves_like 'payment services not called'
          end

          context 'with a list of incompleted expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :incompleted, individual: individual, expert: expert) }

            it_behaves_like 'payment services not called'
          end

          context 'with a list of ongoing expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :ongoing, individual: individual, expert: expert) }

            it_behaves_like 'payment services not called'
          end

          context 'with a list of finished expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :finished, individual: individual, expert: expert) }

            it_behaves_like 'confirmation payment service is called'
          end

          context 'with a list of denied_complaint expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :denied_complaint, individual: individual, expert: expert) }

            it_behaves_like 'confirmation payment service is called'
          end

          context 'with a list of filed_complaint expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :filed_complaint, individual: individual, expert: expert) }

            it_behaves_like 'confirmation payment service is called'
          end

          context 'with a list of approved_complaint expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :approved_complaint, individual: individual, expert: expert) }

            it_behaves_like 'cancelation payment service is called'
          end

          context 'with a list of transfered expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :transfered, individual: individual, expert: expert) }

            it_behaves_like 'payment services not called'
          end

          context 'with a list of refunded expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :refunded, individual: individual, expert: expert) }

            it_behaves_like 'payment services not called'
          end

          context 'with a list of untransferred expert calls' do
            let(:interactions) { create_list(:expert_call, 2, :untransferred, individual: individual, expert: expert) }

            it_behaves_like 'payment services not called'
          end
        end
      end

      context 'with stripe mock and error api call' do
        let(:stripe_error) { 'Missing Payment method' }
        let(:user_profile) do
          profile = as_individual ? interactions.first.individual : interactions.first.expert
          profile.user
        end

        before do
          allow(Stripes::Payments::CancelationHandler).to(
            receive(:call).with(any_args).and_return(OpenStruct.new(error: stripe_error))
          )
          allow(Stripes::Payments::ConfirmationHandler).to(
            receive(:call).with(any_args).and_return(OpenStruct.new(error: stripe_error))
          )
          allow(AccountDeletionFollowUps::TrackerHelper).to(
            receive(:call).with(any_args).and_return(true)
          )
          interactions
          subject # rubocop:todo RSpec/NamedSubject
        end

        context 'with a list of answered quick questions' do
          let(:interactions) { create_list(:quick_question, 2, :answered, individual: individual, expert: expert) }

          it_behaves_like 'follow up tracker service is called for each interaction'
        end

        context 'with a list of denied_complaint quick questions' do
          let(:interactions) { create_list(:quick_question, 2, :denied_complaint, individual: individual, expert: expert) }

          it_behaves_like 'follow up tracker service is called for each interaction'
        end

        context 'with a list of filed_complaint quick questions' do
          let(:interactions) { create_list(:quick_question, 2, :filed_complaint, individual: individual, expert: expert) }

          it_behaves_like 'follow up tracker service is called for each interaction'
        end

        context 'with a list of approved_complaint quick questions' do
          let(:interactions) { create_list(:quick_question, 2, :approved_complaint, individual: individual, expert: expert) }

          it_behaves_like 'follow up tracker service is called for each interaction'
        end

        context 'with a list of finished expert calls' do
          let(:interactions) { create_list(:expert_call, 2, :finished, individual: individual, expert: expert) }

          it_behaves_like 'follow up tracker service is called for each interaction'
        end

        context 'with a list of denied_complaint expert calls' do
          let(:interactions) { create_list(:expert_call, 2, :denied_complaint, individual: individual, expert: expert) }

          it_behaves_like 'follow up tracker service is called for each interaction'
        end

        context 'with a list of filed_complaint expert calls' do
          let(:interactions) { create_list(:expert_call, 2, :filed_complaint, individual: individual, expert: expert) }

          it_behaves_like 'follow up tracker service is called for each interaction'
        end

        context 'with a list of approved_complaint expert calls' do
          let(:interactions) { create_list(:expert_call, 2, :approved_complaint, individual: individual, expert: expert) }

          it_behaves_like 'follow up tracker service is called for each interaction'
        end
      end
    end
  end

  # TODO- Update account deletion flow
  xdescribe 'service initialize as_individual with value true' do
    include_context 'users_for_individual_endpoints'

    let(:as_individual) { true }

    it_behaves_like 'when payment execution service acts as expected'
  end

  xdescribe 'service initialize as_individual with value false' do
    include_context 'users_for_expert_endpoints'

    let(:as_individual) { false }

    it_behaves_like 'when payment execution service acts as expected'
  end

  xdescribe '.call' do
    subject { described_class.call(interactions, as_individual) }

    let(:service) { double('payment_execution_service') } # rubocop:todo RSpec/VerifiedDoubles
    let(:interactions) { nil }
    let(:as_individual) { true }

    it_behaves_like 'class service called'
  end
end
