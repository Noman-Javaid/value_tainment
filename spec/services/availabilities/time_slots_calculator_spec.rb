require 'rails_helper'

describe Availabilities::TimeSlotsCalculator do
  describe '#execute' do
    let(:expert) { create(:expert, :with_profile) }
    let(:expert_timezone) { 'UTC' }
    let!(:expert_device) { create(:device, user: expert.user, timezone: expert_timezone) } # rubocop:todo RSpec/LetSetup
    let(:individual) { create(:individual) }
    let(:individual_timezone) { 'UTC' }
    let!(:individual_device) do # rubocop:todo RSpec/LetSetup
      create(:device, user: individual.user, timezone: individual_timezone)
    end
    let(:availability_settings) do
      {
        monday: false,
        tuesday: false,
        wednesday: false,
        thursday: false,
        friday: false,
        saturday: false,
        sunday: false
      }
    end
    let(:availability) { create(:availability, expert: expert, **availability_settings) }
    let(:initial_time) { '2021-08-16'.in_time_zone(individual_timezone) }
    let(:date_initial) { '2021-08-16' }
    let(:date_end) { '2021-08-19' }
    let(:call_duration) { ExpertCall::DEFAULT_CALL_DURATION }
    let(:described_instance) do
      described_class.new(availability, individual, date_initial, date_end)
    end
    let(:days_available) { [] }
    let(:expected_hash) do
      {
        date_initial: date_initial,
        date_end: date_end,
        call_duration: call_duration,
        days: days_available
      }
    end

    before do
      stub_const('ExpertCall::DEFAULT_CALL_DURATION', 20)
      Timecop.freeze(initial_time)
    end

    after { Timecop.return }

    # context satified by parent
    context 'without days available' do
      let(:days_available) do
        [{ available_time: [], day: '2021-08-16' },
         { available_time: [],  day: '2021-08-17' },
         { available_time: [],  day: '2021-08-18' },
         { available_time: [],  day: '2021-08-19' }]
      end

      it 'returns expected hash' do
        expect(described_instance.execute).to eq(expected_hash)
      end
    end

    context 'with time blocks available in the range sent' do
      context 'when using default call_duration' do
        let(:time_start_weekday) { '09:00:00+00:00' }
        let(:time_end_weekday) do
          (time_start_weekday.in_time_zone('UTC') +
          ExpertCall::DEFAULT_CALL_DURATION.minutes)
            .strftime('%T%:z')
        end
        let(:availability_settings) do
          {
            monday: true,
            time_start_weekday: time_start_weekday,
            time_end_weekday: time_end_weekday
          }
        end

        let(:days_available) do
          [
            {
              day: date_initial,
              available_time: [
                {
                  time_start: time_start_weekday,
                  time_end: time_end_weekday
                }
              ]
            },
            { available_time: [],  day: '2021-08-17' },
            { available_time: [],  day: '2021-08-18' },
            { available_time: [],  day: '2021-08-19' }
          ]
        end

        it 'returns expected hash' do
          expect(described_instance.execute).to(eq(expected_hash))
        end

        context 'when a time block in already taken by an expert call' do
          let(:time_start_available_block) do
            (time_start_weekday.in_time_zone('UTC') +
            ExpertCall::DEFAULT_CALL_DURATION.minutes).strftime('%T%:z')
          end
          let(:time_end_weekday) do
            (time_start_weekday.in_time_zone('UTC') +
              (ExpertCall::DEFAULT_CALL_DURATION.minutes * 2))
              .strftime('%T%:z')
          end
          let!(:expert_call) do # rubocop:todo RSpec/LetSetup
            create(:expert_call, :scheduled, expert: expert,
                                             scheduled_time_start: time_start_weekday.in_time_zone('UTC'))
          end
          let(:days_available) do
            [
              {
                day: date_initial,
                available_time: [
                  {
                    time_start: time_start_available_block,
                    time_end: time_end_weekday
                  }
                ]
              },
              { available_time: [],  day: '2021-08-17' },
              { available_time: [],  day: '2021-08-18' },
              { available_time: [],  day: '2021-08-19' }
            ]
          end

          it 'returns expected hash' do
            expect(described_instance.execute).to(eq(expected_hash))
          end
        end

        context 'when a time block is generated due to timezone differences ' do
          let(:time_start_weekday) { '21:00:00+00:00' }
          let(:time_end_weekday) { '23:00:00+00:00' }
          let(:expert_timezone) { 'UTC' }
          let(:individual_timezone) { 'Africa/Johannesburg' } # UTC+2
          let(:days_available) do
            [
              {
                available_time: [
                  { time_start: '23:00:00+02:00', time_end: '23:20:00+02:00' },
                  { time_start: '23:20:00+02:00', time_end: '23:40:00+02:00' }
                ],
                day: '2021-08-16'
              },
              {
                available_time: [
                  { time_start: '00:00:00+02:00', time_end: '00:20:00+02:00' },
                  { time_start: '00:20:00+02:00', time_end: '00:40:00+02:00' },
                  { time_start: '00:40:00+02:00', time_end: '01:00:00+02:00' }
                ],
                day: '2021-08-17'
              },
              { available_time: [], day: '2021-08-18' },
              { available_time: [], day: '2021-08-19' }
            ]
          end

          it 'returns expected hash' do
            expect(described_instance.execute).to(eq(expected_hash))
          end
        end

        context 'when there are blocks that are already in the past the current_time' do
          let(:time_start_weekday) { '09:00:00+00:00' }
          let(:time_end_weekday) do
            (time_start_weekday.in_time_zone('UTC') +
            ExpertCall::DEFAULT_CALL_DURATION.minutes)
              .strftime('%T%:z')
          end

          let(:initial_time) { '2021-08-16 12:00:00'.in_time_zone(individual_timezone) }

          let(:days_available) do
            [{ available_time: [], day: '2021-08-16' },
             { available_time: [],  day: '2021-08-17' },
             { available_time: [],  day: '2021-08-18' },
             { available_time: [],  day: '2021-08-19' }]
          end

          it 'does not return that block' do
            expect(described_instance.execute).to(eq(expected_hash))
          end
        end

        # immediate slot available (same day as possible scheduled meeting)
        context 'when there is a block in the middle of the current_time' do
          let(:time_adjust) { 10.minutes }
          let(:time_start_weekday) { '11:40:00+00:00' }
          let(:time_end_weekday) do
            (initial_time +
              (ExpertCall::DEFAULT_CALL_DURATION.minutes / 2) +
              ExpertCall::DEFAULT_CALL_DURATION.minutes +
              time_adjust).strftime('%T%:z')
          end

          let(:initial_time) { '2021-08-16 12:00:00'.in_time_zone(individual_timezone) }

          let(:days_available) do
            [
              {
                available_time: [
                  { time_start: '12:15:00+00:00', time_end: '12:35:00+00:00' }
                ],
                day: '2021-08-16'
              },
              { available_time: [],  day: '2021-08-17' },
              { available_time: [],  day: '2021-08-18' },
              { available_time: [],  day: '2021-08-19' }
            ]
          end

          it 'generates blocks for the #min_time_to_schedule_on_current_day' do
            expect(described_instance.execute).to(eq(expected_hash))
          end
        end
      end

      context 'when using a call_duration of 60 minutes' do
        let(:time_start_weekday) { '09:00:00+00:00' }
        let(:call_duration) { 60 }
        let(:time_end_weekday) do
          (time_start_weekday.in_time_zone('UTC') +
          call_duration.minutes)
            .strftime('%T%:z')
        end
        let(:availability_settings) do
          {
            monday: true,
            time_start_weekday: time_start_weekday,
            time_end_weekday: time_end_weekday
          }
        end
        let(:described_instance) do
          described_class.new(
            availability, individual, date_initial, date_end, call_duration
          )
        end
        let(:days_available) do
          [
            {
              day: date_initial,
              available_time: [
                {
                  time_start: time_start_weekday,
                  time_end: time_end_weekday
                }
              ]
            },
            { available_time: [],  day: '2021-08-17' },
            { available_time: [],  day: '2021-08-18' },
            { available_time: [],  day: '2021-08-19' }
          ]
        end

        it 'returns expected hash' do
          expect(described_instance.execute).to(eq(expected_hash))
        end

        context 'when a time block is already taken by an expert call' do
          let(:time_start_available_block) do
            (time_start_weekday.in_time_zone('UTC') +
            call_duration.minutes).strftime('%T%:z')
          end
          let(:time_end_weekday) do
            (time_start_weekday.in_time_zone('UTC') +
              (call_duration.minutes * 2))
              .strftime('%T%:z')
          end
          let!(:expert_call) do # rubocop:todo RSpec/LetSetup
            create(:expert_call, :scheduled, expert: expert,
                                             scheduled_time_start: time_start_weekday.in_time_zone('UTC'))
          end
          let(:days_available) do
            [
              {
                day: date_initial,
                available_time: [
                  {
                    time_start: time_start_available_block,
                    time_end: time_end_weekday
                  }
                ]
              },
              { available_time: [],  day: '2021-08-17' },
              { available_time: [],  day: '2021-08-18' },
              { available_time: [],  day: '2021-08-19' }
            ]
          end

          it 'returns expected hash' do
            expect(described_instance.execute).to(eq(expected_hash))
          end
        end

        context 'when a time block is generated due to timezone differences ' do
          let(:time_start_weekday) { '21:00:00+00:00' }
          let(:time_end_weekday) { '23:00:00+00:00' }
          let(:expert_timezone) { 'UTC' }
          let(:individual_timezone) { 'Africa/Johannesburg' } # UTC+2
          let(:days_available) do
            [
              {
                available_time: [], day: '2021-08-16'
              },
              {
                available_time: [
                  { time_start: '00:00:00+02:00', time_end: '01:00:00+02:00' }
                ],
                day: '2021-08-17'
              },
              { available_time: [], day: '2021-08-18' },
              { available_time: [], day: '2021-08-19' }
            ]
          end

          it 'returns expected hash' do
            expect(described_instance.execute).to(eq(expected_hash))
          end
        end

        context 'when there are blocks that are already in the past the current_time' do
          let(:time_start_weekday) { '09:00:00+00:00' }
          let(:time_end_weekday) do
            (time_start_weekday.in_time_zone('UTC') +
            call_duration.minutes)
              .strftime('%T%:z')
          end

          let(:initial_time) { '2021-08-16 12:00:00'.in_time_zone(individual_timezone) }

          let(:days_available) do
            [{ available_time: [], day: '2021-08-16' },
             { available_time: [],  day: '2021-08-17' },
             { available_time: [],  day: '2021-08-18' },
             { available_time: [],  day: '2021-08-19' }]
          end

          it 'does not return that block' do
            expect(described_instance.execute).to(eq(expected_hash))
          end
        end

        # immediate slot available (same day as possible scheduled meeting)
        context 'when there is a block in the middle of the current_time' do
          let(:time_adjust) { 10.minutes }
          let(:time_start_weekday) { '11:40:00+00:00' }
          let(:time_end_weekday) do
            (initial_time +
              (call_duration.minutes / 2) +
              call_duration.minutes +
              time_adjust).strftime('%T%:z')
          end

          let(:initial_time) { '2021-08-16 12:00:00'.in_time_zone(individual_timezone) }

          let(:days_available) do
            [
              {
                available_time: [
                  { time_start: '12:30:00+00:00', time_end: '13:30:00+00:00' }
                ],
                day: '2021-08-16'
              },
              { available_time: [],  day: '2021-08-17' },
              { available_time: [],  day: '2021-08-18' },
              { available_time: [],  day: '2021-08-19' }
            ]
          end

          it 'generates blocks for the #min_time_to_schedule_on_current_day' do
            expect(described_instance.execute).to(eq(expected_hash))
          end
        end
      end

      context 'when using a call_duration of 15 minutes' do
        let(:time_start_weekday) { '09:00:00+00:00' }
        let(:call_duration) { 15 }
        let(:time_end_weekday) do
          (time_start_weekday.in_time_zone('UTC') +
          call_duration.minutes)
            .strftime('%T%:z')
        end
        let(:availability_settings) do
          {
            monday: true,
            time_start_weekday: time_start_weekday,
            time_end_weekday: time_end_weekday
          }
        end
        let(:described_instance) do
          described_class.new(
            availability, individual, date_initial, date_end, call_duration
          )
        end
        let(:days_available) do
          [
            {
              day: date_initial,
              available_time: [
                {
                  time_start: time_start_weekday,
                  time_end: time_end_weekday
                }
              ]
            },
            { available_time: [],  day: '2021-08-17' },
            { available_time: [],  day: '2021-08-18' },
            { available_time: [],  day: '2021-08-19' }
          ]
        end

        it 'returns expected hash' do
          expect(described_instance.execute).to(eq(expected_hash))
        end

        context 'when a time block is already taken by an expert call' do
          let(:time_start_available_block) do
            (time_start_weekday.in_time_zone('UTC') +
            call_duration.minutes).strftime('%T%:z')
          end
          let(:time_end_weekday) do
            (time_start_weekday.in_time_zone('UTC') +
              (call_duration.minutes * 2))
              .strftime('%T%:z')
          end
          let!(:expert_call) do # rubocop:todo RSpec/LetSetup
            create(:expert_call, :scheduled, expert: expert,
                                             scheduled_time_start: time_start_weekday.in_time_zone('UTC'))
          end
          let(:days_available) do
            [
              {
                day: date_initial,
                available_time: [
                  {
                    time_start: time_start_available_block,
                    time_end: time_end_weekday
                  }
                ]
              },
              { available_time: [],  day: '2021-08-17' },
              { available_time: [],  day: '2021-08-18' },
              { available_time: [],  day: '2021-08-19' }
            ]
          end

          it 'returns expected hash' do
            expect(described_instance.execute).to(eq(expected_hash))
          end
        end

        context 'when a time block is generated due to timezone differences ' do
          let(:time_start_weekday) { '21:00:00+00:00' }
          let(:time_end_weekday) { '23:00:00+00:00' }
          let(:expert_timezone) { 'UTC' }
          let(:individual_timezone) { 'Africa/Johannesburg' } # UTC+2
          let(:days_available) do
            [
              {
                available_time: [
                  { time_start: '23:00:00+02:00', time_end: '23:15:00+02:00' },
                  { time_start: '23:15:00+02:00', time_end: '23:30:00+02:00' },
                  { time_start: '23:30:00+02:00', time_end: '23:45:00+02:00' }
                ],
                day: '2021-08-16'
              },
              {
                available_time: [
                  { time_start: '00:00:00+02:00', time_end: '00:15:00+02:00' },
                  { time_start: '00:15:00+02:00', time_end: '00:30:00+02:00' },
                  { time_start: '00:30:00+02:00', time_end: '00:45:00+02:00' },
                  { time_start: '00:45:00+02:00', time_end: '01:00:00+02:00' }
                ],
                day: '2021-08-17'
              },
              { available_time: [], day: '2021-08-18' },
              { available_time: [], day: '2021-08-19' }
            ]
          end

          it 'returns expected hash' do
            expect(described_instance.execute).to(eq(expected_hash))
          end
        end

        context 'when there are blocks that are already in the past the current_time' do
          let(:time_start_weekday) { '09:00:00+00:00' }
          let(:time_end_weekday) do
            (time_start_weekday.in_time_zone('UTC') +
            call_duration.minutes)
              .strftime('%T%:z')
          end

          let(:initial_time) { '2021-08-16 12:00:00'.in_time_zone(individual_timezone) }

          let(:days_available) do
            [{ available_time: [], day: '2021-08-16' },
             { available_time: [],  day: '2021-08-17' },
             { available_time: [],  day: '2021-08-18' },
             { available_time: [],  day: '2021-08-19' }]
          end

          it 'does not return that block' do
            expect(described_instance.execute).to(eq(expected_hash))
          end
        end

        # immediate slot available (same day as possible scheduled meeting)
        context 'when there is a block in the middle of the current_time' do
          let(:time_adjust) { 10.minutes }
          let(:time_start_weekday) { '11:45:00+00:00' }
          let(:time_end_weekday) do
            (initial_time +
              (call_duration.minutes / 2) +
              call_duration.minutes +
              time_adjust).strftime('%T%:z')
          end

          let(:initial_time) { '2021-08-16 12:00:00'.in_time_zone(individual_timezone) }

          let(:days_available) do
            [
              {
                available_time: [
                  { time_start: '12:15:00+00:00', time_end: '12:30:00+00:00' }
                ],
                day: '2021-08-16'
              },
              { available_time: [],  day: '2021-08-17' },
              { available_time: [],  day: '2021-08-18' },
              { available_time: [],  day: '2021-08-19' }
            ]
          end

          it 'generates blocks for the #min_time_to_schedule_on_current_day' do
            expect(described_instance.execute).to(eq(expected_hash))
          end
        end
      end
    end

    context 'when the availability comes nil' do
      let(:availability) { nil }
      let(:days_available) { [] }

      it 'returns expected hash without available days' do
        expect(described_instance.execute).to(eq(expected_hash))
      end
    end
  end
end
