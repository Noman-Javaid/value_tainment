require 'rails_helper'

describe TwilioServices::SendTwoFactorCodeBySms do
  let(:user) { create(:user, :with_profile) }
  let(:service_instance) { described_class.new(user) }

  describe '#call' do
    include_context 'with Twilio mocks and stubs'

    context 'when user is valid' do
      before do
        # activate 2fa to user
        user.regenerate_two_factor_secret!
      end

      it 'returns a twilio message object' do
        expect(service_instance.call).to eq(twilio_message)
      end
    end
  end

  describe 'when service is initialize with wrong value' do
    let(:phone_error_message) { 'No phone number associated with user' }
    let(:user_error_message) { 'Wrong type of user' }
    let(:otp_error_message) { 'User do not have two factor available' }

    context 'when the service is initalized with an invalid user object' do
      let(:wrong_user) { 'test' }

      it 'raised an ArgumentError Exception' do
        expect { described_class.new(wrong_user) }.to(
          raise_error(ArgumentError, user_error_message)
        )
      end
    end

    context 'when the user do not have a phone_number' do
      let(:user_without_phone) { create(:user) }

      it 'raised an ArgumentError Exception' do
        expect { described_class.new(user_without_phone) }.to(
          raise_error(ArgumentError, phone_error_message)
        )
      end
    end

    context 'when the user do not have two factor enabled' do
      it 'raised an ArgumentError Exception' do
        expect { described_class.new(user) }.to(
          raise_error(ArgumentError, otp_error_message)
        )
      end
    end
  end

  describe 'when service failed to send sms' do
    let(:error) { OpenStruct.new(error: error_message) }

    before do
      # activate 2fa to user
      user.regenerate_two_factor_secret!
    end

    context 'when user has invalid user phone_number' do
      include_context 'with Twilio sms error invalid number'
      let(:error_message) { 'Invalid phone number to send code' }

      it { expect(service_instance.call).to eq(error) }
    end

    context 'when twilio has unknown failure' do
      include_context 'with Twilio unknown error'
      let(:error_message) { 'SMS service unavailable' }

      it { expect(service_instance.call).to eq(error) }
    end
  end
end
