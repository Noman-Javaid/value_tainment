# == Schema Information
#
# Table name: expert_calls
#
#  id                           :uuid             not null, primary key
#  call_status                  :string           default("requires_confirmation"), not null
#  call_time                    :integer          default(0), not null
#  call_type                    :string           not null
#  cancellation_reason          :string(1000)
#  cancelled_at                 :datetime
#  cancelled_by_type            :string
#  description                  :string           not null
#  guests_count                 :integer          default(0), not null
#  payment_status               :string
#  rate                         :integer          not null
#  room_creation_failure_reason :string
#  room_status                  :string           default(NULL)
#  scheduled_call_duration      :integer          default(20), not null
#  scheduled_time_end           :datetime         not null
#  scheduled_time_start         :datetime         not null
#  time_end                     :datetime
#  time_start                   :datetime
#  title                        :string           not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  cancelled_by_id              :uuid
#  category_id                  :integer
#  expert_id                    :uuid             not null
#  individual_id                :uuid             not null
#  payment_id                   :string
#  room_id                      :string
#  stripe_payment_method_id     :string
#
# Indexes
#
#  index_expert_calls_on_cancelled_by   (cancelled_by_type,cancelled_by_id)
#  index_expert_calls_on_category_id    (category_id)
#  index_expert_calls_on_expert_id      (expert_id)
#  index_expert_calls_on_individual_id  (individual_id)
#  index_expert_calls_on_room_status    (room_status)
#
# Foreign Keys
#
#  fk_rails_...  (category_id => categories.id)
#  fk_rails_...  (expert_id => experts.id)
#  fk_rails_...  (individual_id => individuals.id)
#
require 'rails_helper'

RSpec.describe ExpertCall, type: :model do
  RSpec.shared_examples 'when transition from requires_confirmation raises an error' do
    context 'when transition from requires_confirmation to scheduled' do
      it_behaves_like 'it raises an InvalidTransition error', :schedule
    end

    context 'when transition from requires_confirmation to requires_reschedule_confirmation' do
      it_behaves_like 'it raises an InvalidTransition error', :set_as_requires_reschedule_confirmation
    end

    context 'when transition from requires_confirmation to declined' do
      it_behaves_like 'it raises an InvalidTransition error', :decline
    end
  end

  RSpec.shared_examples 'when transition from requires_reschedule_confirmation raises an error' do
    context 'when transition from requires_reschedule_confirmation to scheduled' do
      it_behaves_like 'it raises an InvalidTransition error', :reschedule
    end

    context 'when transition from requires_reschedule_confirmation to declined' do
      it_behaves_like 'it raises an InvalidTransition error', :decline
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:alerts).dependent(:destroy) }
    it { is_expected.to belong_to(:expert) }
    it { is_expected.to belong_to(:individual) }
    it { is_expected.to have_many(:guests) }
    it { is_expected.to have_many(:participant_events) }
    it { is_expected.to have_many(:refunds).dependent(:destroy) }
    it { is_expected.to have_many(:time_additions).dependent(:destroy) }
    it { is_expected.to have_many(:transfers).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:call_type) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:scheduled_call_duration) }
    it { is_expected.to validate_presence_of(:scheduled_time_start) }
    it { is_expected.to validate_presence_of(:scheduled_time_end) }
    it { is_expected.to validate_presence_of(:rate) }
    it { is_expected.to validate_presence_of(:stripe_payment_method_id) }

    it { is_expected.to validate_length_of(:title).is_at_most(50) }
    it { is_expected.to validate_length_of(:description).is_at_most(2000) }

    it 'validates inclusion of call_type' do
      expect(subject).to validate_inclusion_of(:call_type).in_array(# rubocop:todo RSpec/NamedSubject
        [ExpertCall::CALL_TYPE_ONE_TO_ONE, ExpertCall::CALL_TYPE_ONE_TO_FIVE]
      )
    end

    it 'validates inclusion of scheduled_call_duration' do
      expect(subject).to validate_inclusion_of(:scheduled_call_duration).in_array(# rubocop:todo RSpec/NamedSubject
        ExpertCall::VALID_CALL_DURATION_ARRAY
      )
    end

    describe 'with guests' do
      let(:guest_list_ids) { create_list(:individual, 5, :with_profile).map(&:id) }

      describe 'and extra_user' do
        context 'when create' do
          let(:expert_call) { create(:expert_call, :with_1to5, guest_ids: guest_list_ids) }
          let(:extra_users) { expert_call.guests_count - ExpertCall::MAX_GUESTS_NUMBER }
          let(:expected_rate) do
            ((extra_users * expert_call.expert.extra_user_rate) +
              expert_call.expert.one_to_five_video_call_rate) *
              expert_call.scheduled_call_duration
          end

          it 'has correct rate calculation' do
            expect(expert_call.rate).to eq(expected_rate)
          end
        end
      end

      describe 'and no extra_user' do
        context 'when create' do
          let(:expert_call) do
            create(:expert_call, :with_1to5, guest_ids: guest_list_ids[0, 3])
          end
          let(:expected_rate) do
            expert_call.expert.one_to_five_video_call_rate *
              expert_call.scheduled_call_duration
          end

          it 'has correct rate calculation' do
            expect(expert_call.rate).to eq(expected_rate)
          end
        end
      end
    end

    describe 'without guests' do
      context 'when create' do
        let(:expert_call) { create(:expert_call) }
        let(:expected_rate) do
          expert_call.expert.video_call_rate *
            expert_call.scheduled_call_duration
        end

        it 'has correct rate calculation' do
          expect(expert_call.rate).to eq(expected_rate)
        end
      end
    end

    describe 'when scheduled_time_start has a passed date' do
      context 'on creation' do # rubocop:todo RSpec/ContextWording
        let(:expert_call) { build(:expert_call, scheduled_time_start: 3.days.ago) }

        before { expert_call.valid? }

        it 'is not a valid object' do
          expect(expert_call).not_to be_valid
        end

        it 'shows the error message' do
          expect(expert_call.errors[:scheduled_time_start]).to(
            include('can\'t be a passed date')
          )
        end
      end

      context 'on update' do # rubocop:todo RSpec/ContextWording
        let(:expert_call) { create(:expert_call) }

        before do
          expert_call.scheduled_time_start = 3.days.ago
          expert_call.valid?
        end

        it 'is not a valid object' do
          expect(expert_call).not_to be_valid
        end

        it 'shows the error message' do
          expect(expert_call.errors[:scheduled_time_start]).to(
            include('can\'t be a passed date')
          )
        end
      end
    end

    RSpec.shared_examples_for 'call_type does not match with guest number' do
      it 'has correct error message' do
        expect(expert_call.errors[:call_type]).to(
          include('Does not match with the amount of guests')
        )
      end
    end

    describe 'factory object' do
      let(:expert_call) { build(:expert_call) }
      let(:expert_call_1to5) { build(:expert_call, :with_1to5) }
      let(:scheduled_expert_call) { build(:expert_call, :scheduled) }

      it 'has a valid factory for expert_call 1-1' do
        expect(expert_call).to be_valid
      end

      it 'has a valid factory for expert_call 1-5' do
        expect(expert_call_1to5).to be_valid
      end

      it 'has a valid factory for a scheduled expert_call' do
        expect(scheduled_expert_call).to be_valid
      end
    end

    describe '.guest_amount_match_call_type' do
      let(:guest_individual) { create(:individual, :with_profile) }
      let(:expert_call) { build(:expert_call) }

      context 'when call_type is 1-1 and have guests' do
        before { expert_call.guest_ids = [guest_individual.id] }

        it 'is not valid' do
          expect(expert_call).not_to be_valid
        end

        it_behaves_like 'call_type does not match with guest number' do
          before { expert_call.valid? }
        end
      end

      context 'when call_type is 1-5 and have no guests' do
        let(:guest_individual) { create(:individual, :with_profile) }
        let(:expert_call) { build(:expert_call) }

        before { expert_call.call_type = '1-5' }

        it 'is not valid' do
          expect(expert_call).not_to be_valid
        end

        it_behaves_like 'call_type does not match with guest number' do
          before { expert_call.valid? }
        end
      end
    end

    describe '#extra_user_rate' do
      let(:guest_list_ids) { create_list(:individual, 5, :with_profile).map(&:id) }
      let(:expected_value) { 0 }

      context 'with 5 guests' do
        let(:expert_call) { create(:expert_call, :with_1to5, guest_ids: guest_list_ids) }
        let(:expert_extra_user_rate) { expert_call.expert.extra_user_rate }
        let(:extra_users) { expert_call.guests_count - ExpertCall::MAX_GUESTS_NUMBER }
        let(:call_duration_in_minutes) { expert_call.call_time / 60 }
        let(:expected_value) do
          extra_users * expert_extra_user_rate * call_duration_in_minutes
        end

        it 'return expected_value' do
          expect(expert_call.extra_user_rate).to eq(expected_value)
        end
      end

      context 'with 3 guests' do
        let(:expert_call) do
          create(:expert_call, :with_1to5, guest_ids: guest_list_ids[0, 3])
        end

        it 'return expected_value' do
          expect(expert_call.extra_user_rate).to eq(expected_value)
        end
      end

      context 'without guests' do
        let(:expert_call) { create(:expert_call) }

        it 'return expected_value' do
          expect(expert_call.extra_user_rate).to eq(expected_value)
        end
      end
    end

    describe '#extra_users?' do
      let(:guest_list_ids) { create_list(:individual, 5, :with_profile).map(&:id) }
      let(:expected_value) { expert_call.guests_count > ExpertCall::MAX_GUESTS_NUMBER }

      context 'with 5 guests' do
        let(:expected_value) { true }
        let(:expert_call) { create(:expert_call, :with_1to5, guest_ids: guest_list_ids) }

        it 'return expected_value' do
          expect(expert_call.extra_users?).to eq(expected_value)
        end
      end

      context 'with 3 guests' do
        let(:expert_call) do
          create(:expert_call, :with_1to5, guest_ids: guest_list_ids[0, 3])
        end

        it 'return expected_value' do
          expect(expert_call.extra_users?).to eq(expected_value)
        end
      end

      context 'without guests' do
        let(:expert_call) { create(:expert_call) }

        it 'return expected_value' do
          expect(expert_call.extra_users?).to eq(expected_value)
        end
      end
    end

    describe '#available_to_scheduled?' do
      let(:expert) { create(:expert, :with_profile) }
      let!(:scheduled_expert_call) { create(:expert_call, :scheduled, expert: expert) }
      let!(:same_time_expert_call) do
        create(
          :expert_call,
          expert: expert,
          scheduled_time_start: scheduled_expert_call.scheduled_time_start,
          scheduled_time_end: scheduled_expert_call.scheduled_time_end
        )
      end

      let!(:conflict_with_early_expert_call) do
        create(
          :expert_call,
          expert: expert,
          scheduled_time_start: 3.minutes.ago(scheduled_expert_call.scheduled_time_start),
          scheduled_time_end: 3.minutes.ago(scheduled_expert_call.scheduled_time_end)
        )
      end

      let!(:conflict_with_later_expert_call) do
        create(
          :expert_call,
          expert: expert,
          scheduled_time_start: 3.minutes.from_now(scheduled_expert_call.scheduled_time_start),
          scheduled_time_end: 3.minutes.from_now(scheduled_expert_call.scheduled_time_end)
        )
      end

      context 'with an scheduled expert_call within block time range' do
        it 'same_time_expert_call is not available to scheduled' do
          expect(same_time_expert_call).not_to be_available_to_scheduled
        end

        it 'conflict_with_early_expert_call is not available to scheduled' do
          expect(conflict_with_early_expert_call).not_to be_available_to_scheduled
        end

        it 'conflict_with_later_expert_call is not available to scheduled' do
          expect(conflict_with_later_expert_call).not_to be_available_to_scheduled
        end
      end

      context 'without an scheduled expert_call within block time range' do
        before { scheduled_expert_call.destroy }

        it 'returns true' do
          expect(same_time_expert_call).to be_available_to_scheduled
        end
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
    let(:interaction) { create(:expert_call) }

    context 'when has initial state' do
      it { expect(interaction).to be_requires_confirmation }
    end

    context 'when changed from requires_confirmation to expired state' do
      before { interaction.expire }

      it { expect(interaction).to be_expired }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from requires_confirmation to declined state' do
      before { interaction.decline }

      it { expect(interaction).to be_declined }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from requires_confirmation to requires_reschedule_confirmation state' do
      before { interaction.set_as_requires_reschedule_confirmation }

      it { expect(interaction).to be_requires_reschedule_confirmation }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from requires_confirmation to scheduled state' do
      before do
        allow(Stripes::Payments::CapturePaymentHandler).to receive(:call).and_return(Transaction.new)
        interaction.schedule
      end

      it { expect(interaction).to be_scheduled }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from requires_confirmation to refunded state' do
      it 'raised an AASM::InvalidTransition Exception' do
        expect { interaction.refund }.to raise_error(AASM::InvalidTransition)
      end
    end

    context 'when changed from requires_confirmation to transferred state' do
      it 'raised an AASM::InvalidTransition Exception' do
        expect { interaction.transfer }.to raise_error(AASM::InvalidTransition)
      end
    end

    context 'when changed from requires_reschedule_confirmation to expired state' do
      before do
        interaction.update(call_status: 'requires_reschedule_confirmation')
        interaction.expire
      end

      it { expect(interaction).to be_expired }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from requires_reschedule_confirmation to scheduled state' do
      before do
        interaction.update(call_status: 'requires_reschedule_confirmation')
        interaction.reschedule
      end

      it { expect(interaction).to be_scheduled }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from requires_reschedule_confirmation to declined state' do
      before do
        interaction.update(call_status: 'requires_reschedule_confirmation')
        interaction.decline
      end

      it { expect(interaction).to be_declined }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from requires_reschedule_confirmation to refunded state' do
      before { interaction.update(call_status: 'requires_reschedule_confirmation') }

      it 'raised an AASM::InvalidTransition Exception' do
        expect { interaction.refund }.to raise_error(AASM::InvalidTransition)
      end
    end

    context 'when changed from requires_reschedule_confirmation to transferred state' do
      before { interaction.update(call_status: 'requires_reschedule_confirmation') }

      it 'raised an AASM::InvalidTransition Exception' do
        expect { interaction.transfer }.to raise_error(AASM::InvalidTransition)
      end
    end

    context 'when changed from declined to transferred state' do
      before do
        interaction.update(call_status: 'declined')
      end

      it 'raised an AASM::InvalidTransition Exception' do
        expect { interaction.transfer }.to raise_error(AASM::InvalidTransition)
      end
    end

    context 'when changed from declined to refunded state' do
      before do
        interaction.update(call_status: 'declined')
      end

      it 'raised an AASM::InvalidTransition Exception' do
        expect { interaction.refund }.to raise_error(AASM::InvalidTransition)
      end
    end

    context 'when changed from scheduled to ongoing state' do
      before do
        interaction.update(call_status: 'scheduled')
        interaction.set_as_ongoing
      end

      it { expect(interaction).to be_ongoing }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from ongoing to finished state' do
      let(:method_name) { :add_rate_to_expert_pending_events }

      before do
        interaction.update(call_status: 'ongoing')
        interaction.finish
      end

      it { expect(interaction).to be_finished }
      it { expect(account_balance_calculator).to have_received(:call).once }
    end

    context 'when changed from ongoing to ongoing state' do
      before do
        interaction.update(call_status: 'ongoing')
        interaction.set_as_incompleted
      end

      it { expect(interaction).to be_incompleted }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from finished to refunded state' do
      let(:method_name) { :subtract_rate_to_expert_pending_events }

      before do
        interaction.update(call_status: 'finished')
        interaction.refund
      end

      it { expect(interaction).to be_refunded }
      it { expect(account_balance_calculator).to have_received(:call).once }

      it_behaves_like 'has a refund transaction'
    end

    context 'when changed from finished to transfered state' do
      before do
        interaction.update(call_status: 'finished')
        interaction.transfer
      end

      it { expect(interaction).to be_transfered }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from approved_complaint to refunded state' do
      let(:method_name) { :subtract_rate_to_expert_pending_events }

      before do
        interaction.update(call_status: 'approved_complaint')
        interaction.refund
      end

      it { expect(interaction).to be_refunded }
      it { expect(account_balance_calculator).to have_received(:call).once }

      it_behaves_like 'has a refund transaction'
    end

    context 'when changed from approved_complaint to transfer state' do
      before do
        interaction.update(call_status: 'approved_complaint')
      end

      it 'raised an AASM::InvalidTransition Exception' do
        expect { interaction.transfer }.to raise_error(AASM::InvalidTransition)
      end
    end

    context 'when changed from denied_complaint to transfered state' do
      before do
        interaction.update(call_status: 'denied_complaint')
        interaction.transfer
      end

      it { expect(interaction).to be_transfered }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from denied_complaint to refunded state' do
      before do
        interaction.update(call_status: 'denied_complaint')
      end

      it 'raised an AASM::InvalidTransition Exception' do
        expect { interaction.refund }.to raise_error(AASM::InvalidTransition)
      end
    end

    context 'when changed from finished to filed_complaint state' do
      before do
        interaction.update(call_status: 'finished')
        interaction.set_as_filed_complaint
      end

      it { expect(interaction).to be_filed_complaint }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from filed_complaint to approved_complaint state' do
      before do
        interaction.update(call_status: 'filed_complaint')
        interaction.set_as_approved_complaint
      end

      it { expect(interaction).to be_approved_complaint }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from filed_complaint to denied_complaint state' do
      before do
        interaction.update(call_status: 'filed_complaint')
        interaction.set_as_denied_complaint
      end

      it { expect(interaction).to be_denied_complaint }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from finished to untransferred state' do
      before do
        interaction.update(call_status: 'finished')
        interaction.untransfer
      end

      it { expect(interaction).to be_untransferred }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from denied_complaint to untransferred state' do
      before do
        interaction.update(call_status: 'denied_complaint')
        interaction.untransfer
      end

      it { expect(interaction).to be_untransferred }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from declined to unrefunded_for_incompleted_event state' do
      before do
        interaction.update(call_status: 'declined')
        interaction.set_as_unrefunded
      end

      it { expect(interaction).to be_unrefunded_for_incompleted_event }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from failed to unrefunded_for_incompleted_event state' do
      before do
        interaction.update(call_status: 'failed')
        interaction.set_as_unrefunded
      end

      it { expect(interaction).to be_unrefunded_for_incompleted_event }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from incompleted to unrefunded_for_incompleted_event state' do
      before do
        interaction.update(call_status: 'incompleted')
        interaction.set_as_unrefunded
      end

      it { expect(interaction).to be_unrefunded_for_incompleted_event }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from expired to unrefunded_for_incompleted_event state' do
      before do
        interaction.update(call_status: 'expired')
        interaction.set_as_unrefunded
      end

      it { expect(interaction).to be_unrefunded_for_incompleted_event }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from finished to unrefunded state' do
      before do
        interaction.update(call_status: 'finished')
        interaction.unrefund
      end

      it { expect(interaction).to be_unrefunded }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from approved_complaint to unrefunded state' do
      before do
        interaction.update(call_status: 'approved_complaint')
        interaction.unrefund
      end

      it { expect(interaction).to be_unrefunded }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from untransferred to transfered state' do
      before do
        interaction.update(call_status: 'untransferred')
        interaction.set_as_transfer
      end

      it { expect(interaction).to be_transfered }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from unrefunded_for_incompleted_event to refunded state' do
      before do
        interaction.update(call_status: 'unrefunded_for_incompleted_event')
        interaction.set_refund_for_incompleted_event
      end

      it { expect(interaction).to be_refunded }

      it_behaves_like 'service not called', Experts::AccountBalanceCalculator, :new
    end

    context 'when changed from unrefunded to refunded state' do
      let(:method_name) { :subtract_rate_to_expert_pending_events }

      before do
        interaction.update(call_status: 'unrefunded')
        interaction.set_refund
      end

      it { expect(interaction).to be_refunded }
      it { expect(account_balance_calculator).to have_received(:call).once }
    end

    context 'when the refund is successful' do
      let(:method_name) { :subtract_rate_to_expert_pending_events }

      before do
        interaction.update(call_status: 'approved_complaint')
      end

      it { expect { interaction.refund }.to change(Refund, :count).by(1) }
    end

    context 'when the refund is not successful' do
      include_context 'with stripe mocks and stubs for refund creation with '\
                      'api connection error'
      let(:method_name) { :subtract_rate_to_expert_pending_events }

      before do
        interaction.update(call_status: 'approved_complaint')
      end

      it 'raised an AASM::InvalidTransition Exception and Create a new Alert' do
        expect { interaction.refund }.to raise_error(AASM::InvalidTransition).and change(Alert, :count).by(1)
      end
    end

    context 'when the transfer is successful' do
      before do
        interaction.update(call_status: 'finished')
      end

      it { expect { interaction.transfer }.to change(Transfer, :count).by(1) }
    end

    context 'when the transfer is not successful' do
      include_context 'with stripe mocks and stubs for transfer creation with '\
                      'api connection error'
      before do
        interaction.update(call_status: 'finished')
      end

      it 'raised an AASM::InvalidTransition Exception and Create a new Alert' do
        expect { interaction.transfer }.to raise_error(AASM::InvalidTransition).and change(Alert, :count).by(1)
      end
    end

    describe 'guard validations for status transitioning' do
      context 'with inactive individual user' do
        before { interaction.individual.user.update!(active: false) }

        context 'with requires_confirmation call' do
          let(:interaction) { create(:expert_call) }

          it_behaves_like 'when transition from requires_confirmation raises an error'
        end

        context 'with requires_reschedule_confirmation call' do
          let(:interaction) { create(:expert_call, :requires_reschedule_confirmation) }

          it_behaves_like 'when transition from requires_reschedule_confirmation raises an error'
        end

        context 'with scheduled call' do
          let(:interaction) { create(:expert_call, :scheduled) }

          context 'when transition from scheduled to ongoing' do
            it_behaves_like 'it raises an InvalidTransition error', :set_as_ongoing
          end
        end
      end

      context 'with inactive expert user' do
        before { interaction.expert.user.update!(active: false) }

        context 'with requires_confirmation call' do
          let(:interaction) { create(:expert_call) }

          it_behaves_like 'when transition from requires_confirmation raises an error'
        end

        context 'with requires_reschedule_confirmation call' do
          let(:interaction) { create(:expert_call, :requires_reschedule_confirmation) }

          it_behaves_like 'when transition from requires_reschedule_confirmation raises an error'
        end

        context 'with scheduled call' do
          let(:interaction) { create(:expert_call, :scheduled) }

          context 'when transition from scheduled to ongoing' do
            it_behaves_like 'it raises an InvalidTransition error', :set_as_ongoing
          end
        end
      end

      context 'with both active users' do
        context 'with requires_confirmation call' do
          let(:interaction) { create(:expert_call) }
          context 'when transition from requires_confirmation to scheduled' do
            before do
              allow(Stripes::Payments::CapturePaymentHandler).to receive(:call).and_return(Transaction.new)
            end
            it_behaves_like 'it does not raise an error', :schedule
          end

          context 'when transition from requires_confirmation to requires_reschedule_confirmation' do
            it_behaves_like 'it does not raise an error', :set_as_requires_reschedule_confirmation
          end
        end

        context 'with requires_reschedule_confirmation call' do
          let(:interaction) { create(:expert_call, :requires_reschedule_confirmation) }

          context 'when transition from requires_reschedule_confirmation to decline' do
            it_behaves_like 'it does not raise an error', :decline
          end

          context 'when transition from requires_reschedule_confirmation to scheduled' do
            it_behaves_like 'it does not raise an error', :reschedule
          end
        end

        context 'with scheduled call' do
          let(:interaction) { create(:expert_call, :scheduled) }

          context 'when transition from scheduled to ongoing' do
            it_behaves_like 'it does not raise an error', :set_as_ongoing
          end
        end
      end
    end
  end

  describe 'validate expert user active value on create' do
    subject { expert_call }

    let(:expert) { create(:expert, :with_profile) }
    let(:expert_call) { create(:expert_call, expert: expert) }
    let(:error_message) { 'The Expert User is inactive at the moment' }

    context 'when expert is active' do
      it 'creates the quick question' do
        expect(subject).to be_persisted # rubocop:todo RSpec/NamedSubject
      end
    end

    context 'when expert is inactive' do
      before { expert.user.update!(active: false) }

      context 'with invalid factory' do
        let(:expert_call) { build(:expert_call, expert: expert) }

        it 'expert_call is not valid' do
          expect(subject).not_to be_valid # rubocop:todo RSpec/NamedSubject
        end

        it 'expert_call has error message' do
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
    include_context 'list of expert calls'

    xdescribe '.pending_for_completion' do
      it 'returns all calls that are not pending to be processed in payments' do
        expect(described_class.pending_for_completion).to(
          match_array(
            requires_confirmation_calls_list + scheduled_calls_list +
              requires_reschedule_confirmation_calls_list + expired_calls_list +
              declined_calls_list + failed_calls_list + incompleted_calls_list
          )
        )
      end
    end

    describe '.pending_for_transfer' do
      it 'returns all calls pending to be transfer' do
        expect(described_class.pending_for_transfer).to(
          match_array(finished_calls_list + denied_complaint_calls_list)
        )
      end
    end

    describe '.with_payment' do
      before do
        requires_confirmation_calls_list_without_payment_data
        requires_confirmation_calls_list
      end

      it 'returns all calls with payment id' do
        expect(described_class.with_payment).to(
          match_array(requires_confirmation_calls_list)
        )
      end
    end

    describe '.with_payment_success' do
      before do
        requires_confirmation_calls_list_with_payment_requires_confirmation
        requires_confirmation_calls_list_without_payment_data
        requires_confirmation_calls_list
      end

      it 'returns all calls with payment status succeeded' do
        expect(described_class.with_payment_success).to(
          match_array(requires_confirmation_calls_list)
        )
      end
    end
  end
end
