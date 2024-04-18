# == Schema Information
#
# Table name: alerts
#
#  id             :bigint           not null, primary key
#  alert_type     :integer
#  alertable_type :string           not null
#  message        :string
#  note           :string
#  status         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  alertable_id   :uuid             not null
#
require 'rails_helper'

RSpec.describe Alert, type: :model do
  subject { build(:alert) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:alertable) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:message) }
    it { is_expected.to define_enum_for(:alert_type).with_values([:refund, :transfer, :payment_captured, :release_captured_payment]) }
  end

  describe "AASM" do
    it { is_expected.to transition_from(:pending).to(:in_progress).on_event(:process) }
    it { is_expected.to transition_from(:pending).to(:resolved).on_event(:resolve) }
    it { is_expected.to transition_from(:in_progress).to(:resolved).on_event(:resolve) }
  end
end
