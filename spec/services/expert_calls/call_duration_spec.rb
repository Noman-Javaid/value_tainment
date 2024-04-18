require 'rails_helper'

describe ExpertCalls::CallDuration do
  describe '#call' do
    let(:time_addition) { create(:time_addition) }
    let(:service) { described_class.new(time_addition.expert_call) }

    context 'when expert hasn\'t join call' do
      let(:expected_result) { 0 }

      it 'returns expected_result' do
        expect(service.call).to eq(expected_result)
      end
    end

    context 'when expert has been in the call ' do
      let(:initial_minutes_in_call) { 5 }
      let(:expected_result) { initial_minutes_in_call * 60 }
      let(:participant_event_connection) do
        create(:participant_event, expert_call: time_addition.expert_call,
                                   initial: true, expert: true)
      end

      before do
        Timecop.freeze(1.minute.from_now(time_addition.expert_call.created_at))
        participant_event_connection
        Timecop.freeze(initial_minutes_in_call.minutes.from_now)
      end

      after { Timecop.return }

      it 'returns expected_result' do
        expect(service.call).to eq(expected_result)
      end

      context 'when expert has left the call for certain minutes' do
        let(:minutes_absent) { 2 }
        let(:participant_event_disconnection) do
          create(:participant_event, expert_call: time_addition.expert_call,
                                     expert: true, duration: initial_minutes_in_call * 60,
                                     event_name: 'participant-disconnected')
        end

        before do
          participant_event_disconnection
        end

        it 'returns expected_result' do
          expect(service.call).to eq(expected_result)
        end

        context 'when expert rejoin the call after absent' do
          let(:last_minutes_in_call) { 3 }
          let(:expert_time_in_call) { (last_minutes_in_call * 60) + expected_result }
          let(:last_participant_event_connection) do
            create(:participant_event, expert_call: time_addition.expert_call,
                                       expert: true)
          end

          before do
            Timecop.freeze(1.minute.from_now(participant_event_disconnection.created_at))
            last_participant_event_connection
            Timecop.freeze(last_minutes_in_call.minutes.from_now)
          end

          it 'returns expert_time_in_call' do
            expect(service.call).to eq(expert_time_in_call)
          end
        end
      end
    end
  end
end
