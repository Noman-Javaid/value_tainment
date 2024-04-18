# == Schema Information
#
# Table name: devices
#
#  id                     :bigint           not null, primary key
#  app_build              :string
#  device_name            :string
#  environment            :string
#  ios_push_notifications :string
#  language               :string
#  os                     :string
#  os_version             :string
#  time_format            :string
#  timezone               :string
#  token                  :string
#  version                :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  user_id                :bigint           not null
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Device, type: :model do
  let(:device) { create(:device) }

  describe 'has valid factory' do
    context 'when expert user' do
      it { expect(device).to be_valid }
    end
  end

  describe 'ActiveModel validations' do
    it { is_expected.to belong_to(:user) }
  end
end
