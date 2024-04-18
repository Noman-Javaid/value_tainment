RSpec.shared_context 'with Twilio mocks and stubs' do
  let(:message_sid) { 'SM2812602b4290ccbc165' }
  let(:from) { TwilioService::TWILIO_PHONE_NUMBER }
  let(:to) { '+15794332550909' }
  let(:sms_code) { '445566' }
  let(:sms_body_message) { "#{TwilioService::TWILIO_2FA_MESSAGE} #{sms_code}" }
  let(:queued_status) { 'queued' }
  let(:twilio_message) do
    OpenStruct.new(
      body: sms_body_message, status: queued_status, from: from, to: to, sid: message_sid
    )
  end

  before do
    # Sending sms
    allow_any_instance_of(Twilio::REST::Client).to( # rubocop:todo RSpec/AnyInstance
      receive_message_chain(:messages, :create).and_return(twilio_message) # rubocop:todo RSpec/MessageChain
    )
  end
end

RSpec.shared_context 'with Twilio sms error invalid number' do
  let(:status_code) { 400 }
  let(:code) { 21211 }
  let(:message) { 'Unable to create record' }
  let(:more_info) { 'https://www.twilio.com/docs/errors/21211' }
  let(:error_message) { "The 'To' number +1331522205 is not a valid phone number." }
  let(:body) { { 'code' => code, 'more_info' => more_info, 'message' => error_message } }
  let(:error_response) do
    OpenStruct.new(
      status_code: status_code,
      body: body
    )
  end
  let(:error_instance) { Twilio::REST::RestError.new(message, error_response) }

  before do
    # Invalid phone_number to send sms mock
    allow_any_instance_of(Twilio::REST::Client).to( # rubocop:todo RSpec/AnyInstance
      receive_message_chain(:messages, :create).and_raise(error_instance) # rubocop:todo RSpec/MessageChain
    )
  end
end

RSpec.shared_context 'with Twilio unknown error' do
  let(:status_code) { 400 }
  let(:code) { 11111 }
  let(:message) { 'Unable to send sms' }
  let(:more_info) { 'https://www.twilio.com/docs/errors/11111' }
  let(:error_message) { 'Service unavailable' }
  let(:body) { { 'code' => code, 'more_info' => more_info, 'message' => error_message } }
  let(:error_response) do
    OpenStruct.new(
      status_code: status_code,
      body: body
    )
  end
  let(:error_instance) { Twilio::REST::RestError.new(message, error_response) }

  before do
    # unknown error
    allow_any_instance_of(Twilio::REST::Client).to( # rubocop:todo RSpec/AnyInstance
      receive_message_chain(:messages, :create).and_raise(error_instance) # rubocop:todo RSpec/MessageChain
    )
  end
end

RSpec.shared_context 'with Twilio mocks and stubs to close call' do
  let(:duration) { 400 }
  let(:end_time) { 1.minute.ago }
  let(:room_object) { double('video_room') } # rubocop:todo RSpec/VerifiedDoubles
  let(:room_object_response) { OpenStruct.new(duration: duration, end_time: end_time) }

  before do
    allow_any_instance_of(Twilio::REST::Client).to( # rubocop:todo RSpec/AnyInstance
      receive_message_chain(:video, :rooms).and_return(room_object) # rubocop:todo RSpec/MessageChain
    )
    allow(room_object).to(receive(:update).and_return(room_object_response))
  end
end
