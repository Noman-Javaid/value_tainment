class Webhooks::TwilioWebhookService < TwilioService
  def initialize(twilio_params) # rubocop:todo Lint/MissingSuper
    @twilio_params = twilio_params
  end

  def call
    Rails.logger.info("Twilio StatusCallbackEvent -> #{@twilio_params['StatusCallbackEvent']}")
    return update_expert_call if @twilio_params['StatusCallbackEvent'] == ROOM_ENDED_EVENT
    return unless PARTICIPANT_EVENTS.include?(@twilio_params['StatusCallbackEvent'])

    check_participant
    Rails.logger.info("ParticipantIdentity -> #{@expert_call.id}")
  end

  private

  # Check for participant connection or disconnection
  def check_participant
    @expert_call = ExpertCall.find(@twilio_params['RoomName'])
    if @twilio_params['ParticipantIdentity'] == @expert_call.expert_id
      save_event(true)
      check_expert_initial_connection
    else
      save_event
    end
  end

  # rubocop:disable Style/GuardClause
  def update_expert_call
    @expert_call = ExpertCall.find(@twilio_params['RoomName'])
    if @expert_call.ongoing?
      if @expert_call.participant_events.experts.where(expert: true, initial: true).first
        @expert_call.finish
      else
        @expert_call.set_as_incompleted
      end
      @expert_call.update!(time_end: Time.current)
    end
  end
  # rubocop:enable Style/GuardClause

  def check_expert_initial_connection
    return if @expert_call.time_start

    @expert_call.update!(time_start: @twilio_params['Timestamp'])
    @event.update!(initial: true)
  end

  def save_event(expert = false) # rubocop:todo Style/OptionalBooleanParameter
    participant_event_args = {
      participant_id: @twilio_params['ParticipantIdentity'],
      event_name: @twilio_params['StatusCallbackEvent'],
      event_datetime: @twilio_params['Timestamp'],
      expert: expert
    }
    if @twilio_params['StatusCallbackEvent'] == 'participant-disconnected'
      Rails.logger.info('Status participant-disconnected')
      Rails.logger.info("Duration: #{@twilio_params['ParticipantDuration']}")
      participant_event_args.merge!({ duration: @twilio_params['ParticipantDuration'].to_i })
    end

    Rails.logger.info("Participant Event args: #{participant_event_args.inspect}")
    @event = @expert_call.participant_events.create!(participant_event_args)
  end
end
