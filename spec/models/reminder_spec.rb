# == Schema Information
#
# Table name: reminders
#
#  id         :bigint           not null, primary key
#  active     :boolean          default(TRUE), not null
#  detail     :string
#  timer      :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Reminder, type: :model do
  subject(:reminder) { build(:reminder) }

  it 'has a valid factory' do
    expect(build(:reminder)).to be_valid
  end

  describe 'validations' do
    it { expect(reminder).to validate_presence_of(:timer) }
    it { expect(reminder).to validate_numericality_of(:timer) }
  end

  describe 'instance methods' do
    describe 'responds to its methods' do
      it { is_expected.to respond_to(:valid_to_notify?) }
    end

    describe '#valid_to_notify?' do
      let(:current_time) { '1/May/2022 14:00:00 +00:00'.to_datetime }
      # event time is in half hour ahead of current time
      let(:event_time) { '1/May/2022 14:30:00 +00:00'.to_datetime }

      before do
        reminder.timer = timer
        Timecop.freeze(current_time)
      end

      after { Timecop.return }

      context 'when timer adjusted according to event time do not surpass current time' do
        let(:timer) { 0.75 } # 45 minutes

        it 'is not valid' do
          expect(reminder).not_to be_valid_to_notify(event_time)
        end
      end

      context 'when timer adjusted according to event time surpass current time' do
        let(:timer) { 0.25 } # 15 minutes

        it 'is valid' do
          expect(reminder).to be_valid_to_notify(event_time)
        end
      end
    end
  end
end
