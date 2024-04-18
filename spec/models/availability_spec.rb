# == Schema Information
#
# Table name: availabilities
#
#  id                 :bigint           not null, primary key
#  friday             :boolean          default(FALSE), not null
#  monday             :boolean          default(FALSE), not null
#  saturday           :boolean          default(FALSE), not null
#  sunday             :boolean          default(FALSE), not null
#  thursday           :boolean          default(FALSE), not null
#  time_end_weekday   :string
#  time_end_weekend   :string
#  time_start_weekday :string
#  time_start_weekend :string
#  tuesday            :boolean          default(FALSE), not null
#  wednesday          :boolean          default(FALSE), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  expert_id          :uuid             not null
#
# Foreign Keys
#
#  fk_rails_...  (expert_id => experts.id)
#
require 'rails_helper'

RSpec.describe Availability, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:expert) }
  end

  describe 'validations' do
    context 'with time_start and time_end' do
      subject do
        build(:availability, :with_full_time)
      end

      it { is_expected.to allow_value('09:00:00+00:00').for(:time_start_weekday) }
      it { is_expected.to allow_value('16:00:00+00:00').for(:time_end_weekday) }
      it { is_expected.to allow_value('09:00:00+00:00').for(:time_start_weekend) }
      it { is_expected.to allow_value('16:00:00+00:00').for(:time_end_weekend) }
    end

    context 'when time_end_weekday is earlier than time_start_weekday' do
      let(:availability) { build(:availability, :with_full_time) }

      before do
        availability.time_start_weekday = '16:00:00+00:00'
        availability.time_end_weekday = '09:00:00+00:00'
        availability.save
      end

      it 'is not valid' do
        expect(availability).not_to be_valid
      end

      it 'has error message for time_end_weekday' do
        expect(availability.errors[:time_end_weekday]).to(
          include('can\'t be earlier or same as time_start')
        )
      end
    end

    context 'when time_end_weekend is earlier than time_start_weekend' do
      let(:availability) { build(:availability, :with_full_time) }

      before do
        availability.time_start_weekend = '16:00:00+00:00'
        availability.time_end_weekend = '09:00:00+00:00'
        availability.save
      end

      it 'is not valid' do
        expect(availability).not_to be_valid
      end

      it 'has error message for time_end_weekend' do
        expect(availability.errors[:time_end_weekend]).to(
          include('can\'t be earlier or same as time_start')
        )
      end
    end

    context 'when has a weekday and time is not provided' do
      subject { availability }

      let(:availability) { build(:availability) }

      before do
        availability.monday = true
        availability.save
      end

      it 'is not valid' do
        expect(availability).not_to be_valid
      end

      it { is_expected.to validate_presence_of(:time_start_weekday) }

      it { is_expected.to validate_presence_of(:time_end_weekday) }
    end

    context 'when has a weekend and time is not provided' do
      subject { availability }

      let(:availability) { build(:availability) }

      before do
        availability.saturday = true
        availability.save
      end

      it 'is not valid' do
        expect(availability).not_to be_valid
      end

      it { is_expected.to validate_presence_of(:time_start_weekend) }

      it { is_expected.to validate_presence_of(:time_end_weekend) }
    end
  end

  describe 'factory object' do
    context 'when used with default' do
      let(:availability) { build(:availability) }

      it 'has a valid factory for availability' do
        expect(availability).to be_valid
      end
    end

    context 'when used with_full_time' do
      let(:availability) { build(:availability, :with_full_time) }

      it 'has a valid factory for availability' do
        expect(availability).to be_valid
      end
    end
  end

  describe '#weekdays?' do
    let(:availability) { create(:availability, :with_full_time) }

    context 'without weekdays' do
      before do
        availability.update!(
          monday: false, tuesday: false, wednesday: false, thursday: false, friday: false
        )
      end

      it 'return false' do
        expect(availability).not_to be_weekdays
      end
    end

    context 'with weekdays' do
      before do
        availability.update!(monday: true)
      end

      it 'return false' do
        expect(availability).to be_weekdays
      end
    end
  end

  describe '#weekend?' do
    let(:availability) { create(:availability, :with_full_time) }

    context 'without weekdend' do
      before do
        availability.update!(saturday: false, sunday: false)
      end

      it 'return false' do
        expect(availability).not_to be_weekend
      end
    end

    context 'with weekend' do
      before do
        availability.update!(saturday: true)
      end

      it 'return false' do
        expect(availability).to be_weekend
      end
    end
  end

  describe '#get_weekdays_array' do
    let(:availability) { create(:availability, :with_full_time) }

    it 'return an array with full weekday' do
      expect(availability.get_weekdays_array).to(match_array(described_class::WEEKDAYS))
    end
  end

  describe '#get_weekend_array' do
    let(:availability) { create(:availability, :with_full_time) }

    it 'return an array with full weekend' do
      expect(availability.get_weekend_array).to(match_array(described_class::WEEKEND))
    end
  end
end
