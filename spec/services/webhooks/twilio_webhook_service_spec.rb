require 'rails_helper'

describe Webhooks::TwilioWebhookService do
  let(:call_duration) { 15 }
  let(:room_status) { 'completed' }
  let(:room_type) { 'group' }
  let(:room_sid) { 'RMfd93ijf2a' }
  let(:room_duration) { (call_duration * 60).to_s }
  let(:sequence_number) { 20.to_s }
  let(:timestamp) { '2022-06-22T22:23:07.519Z' }
  let(:account_sid) { 'ACdsfjd92f292' }
  let(:room_name) { expert_call.id }
  let(:twilio_params) do
    {
      'RooomStatus' => room_status,
      'RoomType' => room_type,
      'RoomSid' => room_sid,
      'RoomName' => room_name,
      'SequenceNumber' => sequence_number,
      'StatusCallbackEvent' => status_callback_event,
      'Timestamp' => timestamp,
      'AccountSid' => account_sid
    }
  end
  let(:expert_call) do
    create(:expert_call, :ongoing, scheduled_call_duration: call_duration,
                                   scheduled_time_start: 30.seconds.from_now)
  end

  describe '#call' do
    context 'when status callback event is room-ended' do
      let(:status_callback_event) { 'room-ended' }
      let(:twilio_params_in_event) { { 'RoomDuration' => room_duration } }
      let(:participant_event) do
        create(:participant_event, expert_call: expert_call, expert: true, initial: true)
      end

      context 'when the expert joined the call' do
        before do
          participant_event
          described_class.new(twilio_params.merge(twilio_params_in_event)).call
          expert_call.reload
        end

        it 'updates the expert_call to finished' do
          expect(expert_call).to be_finished
        end
      end

      context 'when the expert did not joined the call' do
        before do
          described_class.new(twilio_params.merge(twilio_params_in_event)).call
          expert_call.reload
        end

        it 'updates the expert_call to incompleted' do
          expect(expert_call).to be_incompleted
        end
      end
    end

    context 'when status callback event is related to a participant' do
      let(:participant_identity) { expert_call.expert.id }
      let(:participant_sid) { 'PAdfjsd234f2sd' }
      let(:twilio_params_in_event) do
        {
          'ParticipantStatus' => participant_status,
          'ParticipantIdentity' => participant_identity,
          'ParticipantSid' => participant_sid
        }
      end

      context 'with participant-connected' do
        let(:status_callback_event) { ParticipantEvent::PARTICIPANT_CONNECTED }
        let(:participant_status) { 'connected' }

        before do
          described_class.new(twilio_params.merge(twilio_params_in_event)).call
          expert_call.reload
        end

        it 'creates a participant event for expert_call' do
          expect(expert_call.participant_events.count).to be(1)
        end

        it 'participant event has event_type as participant-connected' do
          expect(expert_call.participant_events.first.event_name).to(
            eq(status_callback_event)
          )
        end
      end

      describe 'with participant-disconnected' do
        let(:status_callback_event) { ParticipantEvent::PARTICIPANT_DISCONNECTED }
        let(:participant_status) { 'disconnected' }
        let(:participant_duration) { '300' }
        let(:participant_disconnected_params) do
          { 'ParticipantDuration' => room_duration }
        end

        before do
          expert_call.update(time_start: 30.seconds.from_now)
          described_class.new(
            twilio_params.merge(twilio_params_in_event)
                         .merge(participant_disconnected_params)
          ).call
          expert_call.reload
        end

        it 'creates a participant event for expert_call' do
          expect(expert_call.participant_events.count).to be(1)
        end

        it 'participant event has event_type as participant-connected' do
          expect(expert_call.participant_events.first.event_name).to(
            eq(status_callback_event)
          )
        end
      end
    end
  end
end
