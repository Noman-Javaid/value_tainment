# == Schema Information
#
# Table name: setting_variables
#
#  id                             :bigint           not null, primary key
#  question_response_time_in_days :integer          not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#
require 'rails_helper'

RSpec.describe SettingVariable, type: :model do
  let(:setting_variable) { build(:setting_variable) }

  it 'has a valid factory' do
    expect(setting_variable).to be_valid
  end

  describe 'validations' do
    it { expect(setting_variable).to validate_presence_of(:question_response_time_in_days) }
    it { expect(setting_variable).to validate_numericality_of(:question_response_time_in_days) }
  end

  describe 'public instance methods' do
    let(:days) { 1 }

    before { setting_variable.update!(question_response_time_in_days: days) }

    describe 'responds to its methods' do
      it { is_expected.to respond_to(:response_time_to_hours) }
      it { is_expected.to respond_to(:response_time_to_minutes) }
    end

    describe '#response_time_to_hours' do
      let(:expected_result) { days * 24 }

      it 'returns correct result' do
        expect(setting_variable.response_time_to_hours).to eq(expected_result)
      end
    end

    describe '#response_time_to_minutes' do
      let(:expected_result) { days * 24 * 60 }

      it 'returns correct result' do
        expect(setting_variable.response_time_to_minutes).to eq(expected_result)
      end
    end
  end
end
