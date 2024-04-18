# == Schema Information
#
# Table name: categories
#
#  id                 :bigint           not null, primary key
#  description        :string
#  interactions_count :integer          default(0), not null
#  name               :string
#  status             :string           default("active")
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
require 'rails_helper'

RSpec.describe Category, type: :model do
  subject(:category) { build(:category) }

  it 'has a valid factory' do
    expect(build(:category)).to be_valid
  end

  describe 'ActiveModel validations' do
    it { expect(category).to validate_presence_of(:name) }
  end
end
