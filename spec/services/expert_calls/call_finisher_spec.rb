require 'rails_helper'

describe ExpertCalls::CallFinisher do
  RSpec.shared_examples_for 'update call_time to twilio_room duration' do
    it { expect(expert_call.call_time).to eq(twilio_room.duration) }
  end

  RSpec.shared_examples_for 'add time_end to twilio_room end_time' do
    it { expect(expert_call.time_end).to eq(twilio_room.end_time) }
  end

  describe '#call' do
    let(:twilio_room) { OpenStruct.new(duration: 1100, end_time: 20.minutes.from_now) }
    let(:twilio_end_expert_call_service) do
      double('twilio_end_expert_call_service', call: twilio_room) # rubocop:todo RSpec/VerifiedDoubles
    end

    before do
      allow(TwilioServices::EndExpertCall).to(
        receive(:new).and_return(twilio_end_expert_call_service)
      )
      described_class.new(expert_call).call
    end

    context 'when expert call is ongoing' do
      context 'when service end call and set expert_call as finished' do
        let(:expert_call) do
          create(:expert_call, :with_participant_events, :ongoing)
        end

        it 'change the call_status to finished' do
          expect(expert_call.call_status).to eq('finished')
        end

        it_behaves_like 'update call_time to twilio_room duration'

        it_behaves_like 'add time_end to twilio_room end_time'
      end

      context 'when service end call and set expert_call as incompleted' do
        let(:expert_call) do
          create(:expert_call, :ongoing)
        end

        it 'change the call_status to incompleted' do
          expect(expert_call.call_status).to eq('incompleted')
        end

        it_behaves_like 'update call_time to twilio_room duration'

        it_behaves_like 'add time_end to twilio_room end_time'
      end
    end

    context 'when expert call is not ongoing' do
      let(:expert_call) do
        create(:expert_call, :finished)
      end

      it_behaves_like 'service not called', TwilioServices::EndExpertCall, :new
    end
  end
end
