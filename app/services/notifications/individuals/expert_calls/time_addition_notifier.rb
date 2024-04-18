module Notifications
  module Individuals
    module ExpertCalls
      class TimeAdditionNotifier
        include Notifications::CommonMethods

        def initialize(time_addition)
          @time_addition = time_addition
          @expert_call = @time_addition.expert_call
        end

        def execute
          send_silent_push_notification(individual_device) if individual_allow_notifications?
          @expert_call.guests.each do |guest|
            next unless guest.allow_notifications

            send_silent_push_notification(guest.user.device)
          end
        end

        private

        # fix silent_push_payload for android
        # Correct
        # {"notification":{"silent":false,"data":{},"type":"deep-link"}}
        # {"notification":{
        #   "silent":true,
        #   "data":{
        #     "event_id":"event_id","event":"ExpertCall",
        #     "event_status":"requires_confirmation"
        #   },
        #   "type":"deep-link"}}
        # Incorrect
        # {"notification":{
        #   "silent":{
        #     "silent":true,
        #     "payload_data":{
        #       "time_addition_status":"pending","expert_name":"Test ExpertTwo",
        #       "individual_name":"Individual name",
        #       "expert_id":"expert_id",
        #       "time_addition_id":"time_addition_id",
        #       "time_addition_duration":900,
        #       "expert_call_id":"expert_call_id",
        #       "individual_id":"individual_id"
        #     },
        #     "with_sound":false
        #   },
        #   "data":{},"type":"deep-link"
        # }}
        # TODO in V2 use same silent_push format for both ios and android

        def send_silent_push_notification(device)
          if device.os == 'Android'
            return PushNotification::SenderJob.perform_later(
              device, 'Confirmation/Rejection Addition Time',
              notification_params[:silent], notification_params[:with_sound],
              notification_params[:payload_data]
            )
          end

          PushNotification::SenderJob.perform_later(
            device, 'Confirmation/Rejection Addition Time', notification_params
          )
        end

        def notification_params
          @notification_params ||= {
            silent: true,
            with_sound: false,
            payload_data: {
              expert_call_id: @expert_call.id,
              expert_id: @expert_call.expert_id,
              expert_name: @expert_call.expert.name,
              individual_id: @expert_call.individual_id,
              individual_name: @expert_call.individual.name,
              time_addition_id: @time_addition.id,
              time_addition_duration: @time_addition.duration,
              time_addition_status: @time_addition.status
            }
          }
        end
      end
    end
  end
end
