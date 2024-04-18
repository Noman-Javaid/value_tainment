class UpdatePolicies < ActiveRecord::Migration[6.1]
  def change
    # update expert policies
    expert_policies = AppPolicy.expert_policies
    if expert_policies.present?
      expert_policies.each do |expert_policy|
        case expert_policy.title
        when 'Cancellation Policy'
          expert_policy.update!(description: ['The user receives a full refund when the expert cancels the call.'])
        when 'Rescheduling Policy'
          expert_policy.update!(description: ['You may reschedule any time up to 24 hours before a call.',
                                              'The new time must be at least 24 hours in the future.',
                                              "If the user accepts the reschedule request the call time will change to the new time.",
                                              'If the user declines your request, the call is canceled and the user receives a full refund.',
                                              'If the user has not responded within 24 hours of the scheduled start time or the proposed time, whichever is sooner, the call stays set for the initially scheduled time.'])
        when 'Suggest New Time Policy'
          expert_policy.update!(description: ['The user will receive a notification that you suggested a new time for the call.',
                                              'If the user accepts your suggested time, the time of the call will update automatically.',
                                              'If the user declines the suggested time, the call will be declined automatically.'])
        end
      end
    end

    individual_policies = AppPolicy.individual_policies
    if individual_policies.present?
      individual_policies.each do |individual_policy|
        case individual_policy.title
        when 'Cancellation Policy'
          individual_policy.update!(description: ['You will receive a full refund for calls canceled at least 24 hours before the scheduled start time.',
                                                  'You will receive a 50% refund for calls canceled between 12 and 24 hours before the scheduled start time',
                                                  'There is no refund for calls canceled within 12 hours of the scheduled start time'])
        when 'Rescheduling Policy'
          individual_policy.update!(description: ['You can request to change the call time up to 24 hours before its scheduled to start.',
                                                  'The new time must be at least 24 hours in the future.',
                                                  'If the expert accepts your request to change the time, the scheduled start time will automatically update on your calendar.',
                                                  'If the expert declines your request to change the time, the call will stay scheduled for the original time.',
                                                  'There is no limit on the number of reschedule requests you can send.',
                                                  'If the expert has not responded within 24 hours of the scheduled start time or the proposed time, whichever is sooner, the call stays set for the initially scheduled time'])
        when 'Scheduling Policy'
          individual_policy.update!(description: ['The expert has 5 days to accept your booking request call.',
                                                  'If you are booking a call that is less than 5 days away the expert has up to 24 hours in advance of the call to accept.',
                                                  'An authorization on your form of payment will be made when you send a booking request.',
                                                  'If a call request expires, or is declined, the authorization will be released.',
                                                  'If the expert accepts your call request, the authorized funds will transfer'])
        end
      end
    end

  end
end
