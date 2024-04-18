require 'rails_helper'

RSpec.describe Utils::SubmitContactForm do
  describe '#call' do
    let(:form_data) do
      {
        name: 'John Doe',
        email: 'john@example.com',
        message: 'Test message'
      }
    end

    context 'when the contact form submission is valid' do
      it 'saves the submission' do
        expect do
          described_class.new(form_data).call
        end.to change(ContactFormSubmission, :count).by(1)
      end
    end

    context 'when the contact form submission is invalid' do
      let(:form_data) do
        {
          name: '',
          email: 'invalid-email',
          message: ''
        }
      end

      it 'does not save the submission and returns errors' do
        result = described_class.new(form_data).call

        expect(result).to be_failure
        expect(result.errors[:error_message]).to eq(["Email is invalid, Message can't be blank"])
      end
    end

    context 'when an error occurs during submission' do
      let(:form_data) do
        {
          name: 'John Doe',
          email: 'john@example.com',
          message: 'Test message'
        }
      end

      before do
        allow_any_instance_of(ContactFormSubmission).to receive(:save).and_raise(StandardError.new('Error'))
      end

      it 'returns an error' do
        result = described_class.new(form_data).call

        expect(result).to be_failure
        expect(result.errors[:error_message]).to eq(['Error'])
      end
    end
  end
end
