module Notifications
  module Experts
    module ExpertCalls
      class TimeAdditionRequestNotifier
        include Notifications::CommonMethods

        def initialize(time_addition)
          @time_addition = time_addition
          @expert_call = @time_addition.expert_call
        end

        def execute
          return unless expert_allow_notifications?

          # TODO: in V2 use same silent_push format for both ios and android
          if expert_device.os == 'Android'
            return PushNotification::SenderJob.perform_later(
              expert_device, 'Requested Time Addition', true, false, payload_data
            )
          end

          PushNotification::SenderJob.perform_later(
            expert_device, 'Requested Time Addition', silent: true,
                                                      payload_data: payload_data, with_sound: false
          )
        end

        private

        def payload_data
          {
            expert_call_id: @expert_call.id,
            expert_id: @expert_call.expert_id,
            expert_name: @expert_call.expert.name,
            individual_id: @expert_call.individual_id,
            individual_name: @expert_call.individual.name,
            time_addition_id: @time_addition.id,
            time_addition_duration: @time_addition.duration,
            time_addition_status: @time_addition.status
          }
        end
      end
    end
  end
end
