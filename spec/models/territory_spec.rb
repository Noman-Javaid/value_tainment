# == Schema Information
#
# Table name: territories
#
#  id          :bigint           not null, primary key
#  active      :boolean          default(TRUE), not null
#  alpha2_code :string           not null
#  name        :string           not null
#  phone_code  :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'rails_helper'

RSpec.describe Territory, type: :model do
  describe 'has valid factory' do
    let(:us_territory) { build(:territory) }
    let(:germany_territory) { build(:territory, :with_germany) }
    let(:uk_territory) { build(:territory, :with_united_kingdom) }
    let(:spain_territory) { build(:territory, :with_spain) }
    let(:france_territory) { build(:territory, :with_france) }

    it { expect(us_territory).to be_valid }

    it { expect(germany_territory).to be_valid }

    it { expect(uk_territory).to be_valid }

    it { expect(spain_territory).to be_valid }

    it { expect(france_territory).to be_valid }
  end

  describe 'ActiveModel validations' do
    subject(:territory) { build(:territory) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_presence_of(:phone_code) }
    it { is_expected.to validate_length_of(:phone_code).is_at_least(1) }
    it { is_expected.to validate_length_of(:phone_code).is_at_most(3) }
    it { is_expected.to validate_presence_of(:alpha2_code) }
    it { is_expected.to validate_uniqueness_of(:alpha2_code) }
    it { is_expected.to validate_inclusion_of(:alpha2_code).in_array(ISO3166::Country.all.map(&:alpha2)) }

    context 'with phone_code invalid format' do
      it { is_expected.not_to allow_value('+32').for(:phone_code) }
    end

    context 'with phone_code valid format' do
      it { is_expected.to allow_value('1').for(:phone_code) }
    end
  end

  describe ".active" do
    let!(:active_territory) { create(:territory, active: true, alpha2_code: 'HK') }
    let!(:inactive_territory) { create(:territory, :with_germany, active: false) }

    it "returns only active records" do
      active_territories = Territory.active

      expect(active_territories).to include(active_territory)
      expect(active_territories).not_to include(inactive_territory)
    end
  end
end
