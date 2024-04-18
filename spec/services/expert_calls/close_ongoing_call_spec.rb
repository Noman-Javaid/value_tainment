require 'rails_helper'

describe ExpertCalls::CloseOngoingCall do
  describe '#call' do
    context 'when service end call' do
      let(:call_duration) { 15 }
      let(:call_finisher) { double('call_finisher', call: nil) } # rubocop:todo RSpec/VerifiedDoubles
      let(:expert_call) do
        create(:expert_call, :ongoing, scheduled_call_duration: call_duration,
                                       scheduled_time_start: 30.seconds.from_now)
      end
      let(:participant_event_connection) do
        create(:participant_event, expert_call: expert_call,
                                   initial: true, expert: true)
      end
      let(:twilio_room) { OpenStruct.new(duration: 1100, end_time: 20.minutes.from_now) }

      before do
        allow(ExpertCalls::CallFinisher).to receive(:new).and_return(call_finisher)
        expert_call
      end

      after { Timecop.return }

      context 'when expert did not join the call' do
        context 'when call still have time' do
          before do
            Timecop.freeze((call_duration - 5).minutes.from_now)
            described_class.new(expert_call).call
          end

          it 'did not executed call_finisher service' do
            expect(call_finisher).not_to have_received(:call)
          end
        end

        context 'when call do not have remaining time' do
          before do
            Timecop.freeze((call_duration + 5).minutes.from_now)
            described_class.new(expert_call).call
          end

          it 'executed call_finisher service' do
            expect(call_finisher).to have_received(:call).once
          end
        end
      end

      context 'when expert join the call and stayed longer than call duration' do
        before do
          participant_event_connection
          Timecop.freeze((call_duration + 5).minutes.from_now)
          described_class.new(expert_call).call
        end

        it 'executed call_finisher service' do
          expect(call_finisher).to have_received(:call).once
        end
      end

      context 'when expert join the call and did not rejoin the call' do
        let(:participant_event_disconnection) do
          create(:participant_event, expert_call: expert_call,
                                     expert: true, duration: (call_duration - 5) * 60,
                                     event_name: 'participant-disconnected')
        end

        before do
          participant_event_connection
          Timecop.freeze((call_duration - 5).minutes.from_now)
          participant_event_disconnection
          Timecop.freeze((call_duration + 5).minutes.from_now)
          described_class.new(expert_call).call
        end

        it 'executed call_finisher service' do
          expect(call_finisher).to have_received(:call).once
        end
      end
    end
  end
end
