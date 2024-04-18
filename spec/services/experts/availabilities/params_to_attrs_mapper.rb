require 'rails_helper'

describe Experts::Availabilities::ParamsToAttrsMapper do # rubocop:todo RSpec/FilePath
  describe '#call' do
    let(:expert) { create(:expert, :with_profile) }
    let(:availability_params) do
      {
        weekdays: {
          days: %w[monday tuesday wednesday],
          time_start: '09:00:00+00:00',
          time_end: '16:00:00+00:00'
        },
        weekend: {
          days: [],
          time_start: nil,
          time_end: nil
        },
        expert_id: expert.id
      }
    end

    it 'has monday as true' do
      expect(described_class.new(availability_params).call[:monday]).to be_truthy
    end

    it 'has tuesday as true' do
      expect(described_class.new(availability_params).call[:tuesday]).to be_truthy
    end

    it 'has wednesday as true' do
      expect(described_class.new(availability_params).call[:wednesday]).to be_truthy
    end

    it 'has thursday as false' do
      expect(described_class.new(availability_params).call[:thursday]).to be_falsey
    end

    it 'has friday as false' do
      expect(described_class.new(availability_params).call[:friday]).to be_falsey
    end

    it 'has saturday as false' do
      expect(described_class.new(availability_params).call[:saturday]).to be_falsey
    end

    it 'has sunday as false' do
      expect(described_class.new(availability_params).call[:sunday]).to be_falsey
    end

    it 'has time_start_weekday as availability_params' do
      expect(described_class.new(availability_params).call[:time_start_weekday]).to(
        eq(availability_params[:weekdays][:time_start])
      )
    end

    it 'has time_end_weekday as availability_params' do
      expect(described_class.new(availability_params).call[:time_end_weekday]).to(
        eq(availability_params[:weekdays][:time_end])
      )
    end

    it 'has time_start_weekend as availability_params' do
      expect(described_class.new(availability_params).call[:time_start_weekend]).to(
        eq(availability_params[:weekend][:time_start])
      )
    end

    it 'has time_end_weekend as availability_params' do
      expect(described_class.new(availability_params).call[:time_end_weekend]).to(
        eq(availability_params[:weekend][:time_end])
      )
    end

    it 'has same expert as availability_params' do
      expect(described_class.new(availability_params).call[:expert_id]).to(
        eq(availability_params[:expert_id])
      )
    end
  end
end
