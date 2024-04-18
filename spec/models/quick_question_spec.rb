# == Schema Information
#
# Table name: quick_questions
#
#  id                       :uuid             not null, primary key
#  answer                   :text
#  answer_date              :datetime
#  answer_type              :string           default("choose")
#  description              :text             not null
#  payment_status           :string
#  question                 :string           not null
#  rate                     :integer          default(0), not null
#  response_time            :integer
#  status                   :string           default("pending")
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  category_id              :integer
#  expert_id                :uuid             not null
#  individual_id            :uuid             not null
#  payment_id               :string
#  refund_id                :string
#  stripe_payment_method_id :string
#
# Indexes
#
#  index_quick_questions_on_category_id    (category_id)
#  index_quick_questions_on_expert_id      (expert_id)
#  index_quick_questions_on_individual_id  (individual_id)
#
# Foreign Keys
#
#  fk_rails_...  (expert_id => experts.id)
#  fk_rails_...  (individual_id => individuals.id)
#
require 'rails_helper'

RSpec.describe QuickQuestion, type: :model do
  RSpec.shared_examples 'when transition from pending raises an error' do
    context 'when transition from pending to draft_answered' do
      it_behaves_like 'it raises an InvalidTransition error', :set_as_draft_answered
    end

    context 'when transition from pending to answered' do
      it_behaves_like 'it raises an InvalidTransition error', :set_as_answered
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:expert) }
    it { is_expected.to belong_to(:individual) }
    it { is_expected.to have_many(:alerts).dependent(:destroy) }
    it { is_expected.to have_many(:refunds).dependent(:destroy) }
    it { is_expected.to have_many(:transfers).dependent(:destroy) }
  end

  describe 'method delegation' do
    it { is_expected.to delegate_method(:name).to(:expert).with_prefix }
    it { is_expected.to delegate_method(:quick_question_rate).to(:expert).with_prefix }
    it { is_expected.to delegate_method(:url_picture).to(:expert).with_prefix }
    it { is_expected.to delegate_method(:status).to(:expert).with_prefix }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:expert) }
    it { is_expected.to validate_presence_of(:individual) }
    it { is_expected.to validate_presence_of(:question) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:rate) }
    it { is_expected.to validate_presence_of(:stripe_payment_method_id) }

    it { is_expected.to validate_length_of(:question).is_at_most(50) }
    it { is_expected.to validate_length_of(:description).is_at_most(2000) }
    it { is_expected.to validate_length_of(:answer).is_at_most(5000) }
  end

  describe 'public instance methods' do
    let(:quick_question) { create(:quick_question) }
    let(:attachment) { create(:attachment, in_bucket: true, quick_question: quick_question) }

    describe 'responds to its methods' do
      it { is_expected.to respond_to(:time_left) }
      it { is_expected.to respond_to(:allow_to_upload_attachment?) }
    end

    describe 'executes methods correctly' do
      describe '#display_name' do
        it { expect(quick_question.display_name).to eq(quick_question.question) }
      end

      describe '#allow_to_upload_attachment?' do
        context 'when has valid status to upload files' do
          before do
            allow(Stripes::Payments::CapturePaymentHandler).to receive(:call).and_return(Transaction.new)
            quick_question.set_as_draft_answered
          end

          it { expect(quick_question).to be_allow_to_upload_attachment }
        end

        context 'when has invalid status to upload files' do
          before do
            allow(Stripes::Payments::CapturePaymentHandler).to receive(:call).and_return(Transaction.new)
            quick_question.update(answer: 'answer', answer_date: Time.current)
          end

          it { expect(quick_question).not_to be_allow_to_upload_attachment }
        end
      end

      describe '#attachment_url?' do
        context 'when has an attachment file uploaded in s3' do
          before do
            quick_question.set_as_draft_answered
            attachment
          end

          it { expect(quick_question).to be_attachment_url }
        end

        context 'when has an attachment but file not uploaded in s3' do
          before do
            quick_question.set_as_draft_answered
            attachment.update!(in_bucket: false)
          end

          it { expect(quick_question).not_to be_attachment_url }
        end

        context 'when do not have an attachment' do
          it { expect(quick_question).not_to be_attachment_url }
        end
      end
    end

    describe 'state machine transitioning' do
      include_context 'account balance calculator mocks'
      include_context 'with stripe mocks and stubs for successful refund creation'
      include_context 'with refund data for interaction'
      include_context 'with stripe mocks and stubs for successful transfer creation'
      include_context 'with transfer creation constants stubs'
      include_context 'with transfer data for interaction'
      include_context 'refund event'

      let(:method_name) { nil }
      let(:interaction) { create(:quick_question) }

      context 'when has initial state' do
        it { expect(interaction).to be_pending }
      end

      context 'when changed from pending to expired state' do
        before { interaction.expire }

        it { expect(interaction).to be_expired }

        it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
      end

      context 'when changed from pending to draft_answered state' do
        before { interaction.set_as_draft_answered }

        it { expect(interaction).to be_draft_answered }

        it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
      end

      context 'when changed from pending to answered state' do
        let(:method_name) { :add_rate_to_expert_pending_events }

        before do
          allow(Stripes::Payments::CapturePaymentHandler).to receive(:call).and_return(Transaction.new)
          interaction.set_as_answered
        end

        it { expect(interaction).to be_answered }
        it { expect(account_balance_calculator).to have_received(:call).once }
      end

      context 'when changed from pending to refunded state' do
        it 'raised an AASM::InvalidTransition Exception' do
          expect { interaction.refund }.to raise_error(AASM::InvalidTransition)
        end
      end

      context 'when changed from pending to transfered state' do
        it 'raised an AASM::InvalidTransition Exception' do
          expect { interaction.transfer }.to raise_error(AASM::InvalidTransition)
        end
      end

      context 'when changed from draft_answered to expired state' do
        before do
          allow(Stripes::Payments::CapturePaymentHandler).to receive(:call).and_return(Transaction.new)
          interaction.update(status: 'draft_answered')
          interaction.expire
        end

        it { expect(interaction).to be_expired }

        it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
      end

      context 'when changed from draft_answered to answered state' do
        let(:method_name) { :add_rate_to_expert_pending_events }

        before do
          allow(Stripes::Payments::CapturePaymentHandler).to receive(:call).and_return(Transaction.new)
          interaction.update(status: 'draft_answered')
          interaction.set_as_answered
        end

        it { expect(interaction).to be_answered }

        it { expect(account_balance_calculator).to have_received(:call).once }
      end

      context 'when changed from draft_answered to refunded state' do
        before { interaction.update(status: 'draft_answered') }

        it 'raised an AASM::InvalidTransition Exception' do
          expect { interaction.refund }.to raise_error(AASM::InvalidTransition)
        end
      end

      context 'when changed from draft_answered to transfered state' do
        before { interaction.update(status: 'draft_answered') }

        it 'raised an AASM::InvalidTransition Exception' do
          expect { interaction.transfer }.to raise_error(AASM::InvalidTransition)
        end
      end

      context 'when changed from answered to refunded state' do
        let(:method_name) { :subtract_rate_to_expert_pending_events }

        before do
          interaction.update(status: 'answered')
          interaction.refund
        end

        it { expect(interaction).to be_refunded }
        it { expect(account_balance_calculator).to have_received(:call).once }

        it_behaves_like 'has a refund transaction'
      end

      context 'when changed from answered to transfered state' do
        before do
          interaction.update(status: 'answered')
          interaction.transfer
        end

        it { expect(interaction).to be_transfered }

        it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
      end

      context 'when changed from expired to refunded state' do
        before do
          interaction.update(status: 'expired')
          interaction.set_as_refunded
        end

        it { expect(interaction).to be_refunded }

        it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new

        it_behaves_like 'has a refund transaction'
      end

      context 'when changed from expired to transfered state' do
        before { interaction.update(status: 'expired') }

        it 'raised an AASM::InvalidTransition Exception' do
          expect { interaction.transfer }.to raise_error(AASM::InvalidTransition)
        end
      end

      context 'when changed from approved_complaint to refunded state' do
        let(:method_name) { :subtract_rate_to_expert_pending_events }

        before do
          interaction.update(status: 'approved_complaint')
          interaction.refund
        end

        it { expect(interaction).to be_refunded }
        it { expect(account_balance_calculator).to have_received(:call).once }

        it_behaves_like 'has a refund transaction'
      end

      context 'when changed from approved_complaint to transfer state' do
        before do
          interaction.update(status: 'approved_complaint')
        end

        it 'raised an AASM::InvalidTransition Exception' do
          expect { interaction.transfer }.to raise_error(AASM::InvalidTransition)
        end
      end

      context 'when changed from denied_complaint to transfered state' do
        before do
          interaction.update(status: 'denied_complaint')
          interaction.transfer
        end

        it { expect(interaction).to be_transfered }

        it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
      end

      context 'when changed from denied_complaint to refunded state' do
        before do
          interaction.update(status: 'denied_complaint')
        end

        it 'raised an AASM::InvalidTransition Exception' do
          expect { interaction.refund }.to raise_error(AASM::InvalidTransition)
        end
      end

      context 'when changed from answered to filed_complaint state' do
        before do
          interaction.update(status: 'answered')
          interaction.set_as_filed_complaint
        end

        it { expect(interaction).to be_filed_complaint }

        it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
      end

      context 'when changed from filed_complaint to approved_complaint state' do
        before do
          interaction.update(status: 'filed_complaint')
          interaction.set_as_approved_complaint
        end

        it { expect(interaction).to be_approved_complaint }

        it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
      end

      context 'when changed from filed_complaint to denied_complaint state' do
        before do
          interaction.update(status: 'filed_complaint')
          interaction.set_as_denied_complaint
        end

        it { expect(interaction).to be_denied_complaint }

        it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
      end

      context 'when changed from answered to untransferred state' do
        before do
          interaction.update(status: 'answered')
          interaction.untransfer
        end

        it { expect(interaction).to be_untransferred }

        it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
      end

      context 'when changed from denied_complaint to untransferred state' do
        before do
          interaction.update(status: 'denied_complaint')
          interaction.untransfer
        end

        it { expect(interaction).to be_untransferred }

        it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
      end

      context 'when changed from answered to unrefunded state' do
        before do
          interaction.update(status: 'answered')
          interaction.unrefund
        end

        it { expect(interaction).to be_unrefunded }

        it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
      end

      context 'when changed from approved_complaint to unrefunded state' do
        before do
          interaction.update(status: 'approved_complaint')
          interaction.unrefund
        end

        it { expect(interaction).to be_unrefunded }

        it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
      end

      context 'when changed from expired to unrefunded_for_incompleted_event state' do
        before do
          interaction.update(status: 'expired')
          interaction.set_as_unrefunded
        end

        it { expect(interaction).to be_unrefunded_for_incompleted_event }

        it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
      end

      context 'when changed from untransferred to transfered state' do
        before do
          interaction.update(status: 'untransferred')
          interaction.set_as_transfer
        end

        it { expect(interaction).to be_transfered }

        it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
      end

      context 'when changed from unrefunded_for_incompleted_event to refunded state' do
        before do
          interaction.update(status: 'unrefunded_for_incompleted_event')
          interaction.set_refund_for_incompleted_event
        end

        it { expect(interaction).to be_refunded }

        it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
      end

      context 'when changed from unrefunded to refunded state' do
        let(:method_name) { :subtract_rate_to_expert_pending_events }

        before do
          interaction.update(status: 'unrefunded')
          interaction.set_refund
        end

        it { expect(interaction).to be_refunded }
        it { expect(account_balance_calculator).to have_received(:call).once }

        it_behaves_like 'does not have a refund transaction'
      end

      context 'when the refund is successful' do
        let(:method_name) { :subtract_rate_to_expert_pending_events }

        before do
          interaction.update(status: 'answered')
        end

        it { expect { interaction.refund }.to change(Refund, :count).by(1) }
      end

      context 'when the refund is not successful' do
        include_context 'with stripe mocks and stubs for refund creation with '\
                        'api connection error'
        let(:method_name) { :subtract_rate_to_expert_pending_events }

        before do
          interaction.update(status: 'answered')
        end

        it 'raised an AASM::InvalidTransition Exception and Create a new Alert' do
          expect { interaction.refund }.to raise_error(AASM::InvalidTransition).and change(Alert, :count).by(1)
        end
      end

      context 'when the transfer is successful' do
        before do
          interaction.update(status: 'answered')
        end

        it { expect { interaction.transfer }.to change(Transfer, :count).by(1) }
      end

      context 'when the transfer is not successful' do
        include_context 'with stripe mocks and stubs for transfer creation with '\
                        'api connection error'
        before do
          interaction.update(status: 'answered')
        end

        it 'raised an AASM::InvalidTransition Exception and Create a new Alert' do
          expect { interaction.transfer }.to raise_error(AASM::InvalidTransition).and change(Alert, :count).by(1)
        end
      end
    end
  end

  describe 'public class methods' do
    describe 'responds to its methods' do
      it { expect(described_class).to respond_to(:time_to_answer) }
    end

    describe '.time_to_answer' do
      context 'when there are no records of SettingVariable' do
        let(:expected_time) { QuickQuestion::DEFAULT_HOURS_TO_ANSWER }

        it 'returns DEFAULT_HOURS_TO_ANSWER' do
          expect(described_class.time_to_answer).to eq(expected_time)
        end
      end

      context 'when there is a record of SettingVariable' do
        let(:days) { 1 }
        let(:expected_time) { days * 24 }
        let(:response_time) do
          create(:setting_variable, question_response_time_in_days: days)
        end

        before { response_time }

        it 'returns value in minutes from record' do
          expect(described_class.time_to_answer).to eq(expected_time)
        end
      end
    end
  end

  describe 'guard validations for status transitioning' do
    context 'with inactive individual user' do
      before { interaction.individual.user.update!(active: false) }

      context 'with pending question' do
        let(:interaction) { create(:quick_question) }

        it_behaves_like 'when transition from pending raises an error'
      end

      context 'with draft_answered question' do
        let(:interaction) { create(:quick_question, :draft_answered) }

        context 'when transition from draft_answered to answered' do
          it_behaves_like 'it raises an InvalidTransition error', :set_as_answered
        end
      end
    end

    context 'with inactive expert user' do
      before { interaction.expert.user.update!(active: false) }

      context 'with pending question' do
        let(:interaction) { create(:quick_question) }

        it_behaves_like 'when transition from pending raises an error'
      end

      context 'with draft_answered question' do
        let(:interaction) { create(:quick_question, :draft_answered) }

        context 'when transition from draft_answered to answered' do
          it_behaves_like 'it raises an InvalidTransition error', :set_as_answered
        end
      end
    end

    context 'with both active users' do
      context 'with pending question' do
        let(:interaction) { create(:quick_question) }

        before do
          allow(Stripes::Payments::CapturePaymentHandler).to receive(:call).and_return(Transaction.new)
        end

        context 'when transition from pending to draft_answered' do
          it_behaves_like 'it does not raise an error', :set_as_draft_answered
        end

        context 'when transition from pending to answered' do
          it_behaves_like 'it does not raise an error', :set_as_answered
        end
      end

      context 'with draft_answered question' do
        before do
          allow(Stripes::Payments::CapturePaymentHandler).to receive(:call).and_return(Transaction.new)
        end
        let(:interaction) { create(:quick_question, :draft_answered) }

        context 'when transition from draft_answered to answered' do
          it_behaves_like 'it does not raise an error', :set_as_answered
        end
      end
    end
  end

  describe 'validate expert user active value on create' do
    subject { quick_question }

    let(:expert) { create(:expert, :with_profile) }
    let(:quick_question) { create(:quick_question, expert: expert) }
    let(:error_message) { 'The Expert User is inactive at the moment' }

    context 'when expert is active' do
      it 'creates the quick question' do
        expect(subject).to be_persisted # rubocop:todo RSpec/NamedSubject
      end
    end

    context 'when expert is inactive' do
      before { expert.user.update!(active: false) }

      context 'with invalid factory' do
        let(:quick_question) { build(:quick_question, expert: expert) }

        it 'quick_question is not valid' do
          expect(subject).not_to be_valid # rubocop:todo RSpec/NamedSubject
        end

        it 'quick_question has error message' do
          subject.valid? # rubocop:todo RSpec/NamedSubject
          expect(subject.errors.full_messages).to include(error_message) # rubocop:todo RSpec/NamedSubject
        end
      end

      it 'raises an error' do
        expect { subject }.to raise_error(ActiveRecord::RecordInvalid) # rubocop:todo RSpec/NamedSubject
      end
    end
  end

  describe 'scopes' do
    include_context 'users_for_expert_endpoints'
    include_context 'list of quick questions'

    xdescribe '.pending_for_completion' do
      it 'returns all questions that are not pending to be processed in payments' do
        expect(described_class.pending_for_completion).to(
          match_array(
            pending_questions_list + draft_answered_questions_list +
            expired_questions_list + failed_questions_list
          )
        )
      end
    end

    describe '.pending_for_transfer' do
      it 'returns all questions that are pending to be processed in payments' do
        expect(described_class.pending_for_transfer).to(
          match_array(
            answered_questions_list + denied_complaint_questions_list
          )
        )
      end
    end

    describe '.with_payment' do
      before do
        pending_questions_list_without_payment_data
        pending_questions_list
      end

      it 'returns all calls with payment id' do
        expect(described_class.with_payment).to(
          match_array(pending_questions_list)
        )
      end
    end

    describe '.with_payment_success' do
      before do
        pending_questions_list_with_payment_requires_confirmation
        pending_questions_list_without_payment_data
        pending_questions_list
      end

      it 'returns all calls with payment status succeeded' do
        expect(described_class.with_payment_success).to(
          match_array(pending_questions_list)
        )
      end
    end
  end
end
