# == Schema Information
#
# Table name: participant_events
#
#  id             :bigint           not null, primary key
#  duration       :integer
#  event_datetime :datetime         not null
#  event_name     :string           not null
#  expert         :boolean          default(FALSE), not null
#  initial        :boolean          default(FALSE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  expert_call_id :uuid             not null
#  participant_id :string           not null
#
# Foreign Keys
#
#  fk_rails_...  (expert_call_id => expert_calls.id)
#
require 'rails_helper'

RSpec.describe ParticipantEvent, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:expert_call) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:participant_id) }
    it { is_expected.to validate_presence_of(:event_name) }
    it { is_expected.to validate_presence_of(:event_datetime) }
  end

  describe 'factory object' do
    let(:participant_event) { build(:expert_call) }

    it 'has a valid factory for expert_participant_event' do
      expect(participant_event).to be_valid
    end
  end

  describe '#participant' do
    context 'when the participant is an expert' do
      subject { create(:participant_event, :expert_connection) }

      it { expect(subject.participant).to be_a(Expert) } # rubocop:todo RSpec/NamedSubject
    end

    context 'when the participant is an individual' do
      subject { create(:participant_event, :individual_connection) }

      it { expect(subject.participant).to be_a(Individual) } # rubocop:todo RSpec/NamedSubject
    end
  end
end
