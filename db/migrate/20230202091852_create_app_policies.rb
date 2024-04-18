class CreateAppPolicies < ActiveRecord::Migration[6.1]
  def change
    create_table :app_policies do |t|
      t.string :title, null: false
      t.string :description, array: true, default: []
      t.boolean :expert
      t.boolean :individual
      t.boolean :global, default: false
      t.boolean :has_changed, default: true
      t.string :version
      t.string :status, default: 'active'

      t.timestamps
    end

    # create cancellation policy
    # for individual
    AppPolicy.create(title: 'Cancellation Policy',
                     description: ['You will receive a full refund for calls canceled at least 24 hours before the scheduled start time',
                                   'You will receive a 50 % refund for calls canceled between 12 and 24 hours before the scheduled start time',
                                   'There is no refund for calls canceled within 12 hours of the scheduled start time'],
                     expert: false, individual: true, global: false, version: '1.0')
    # for expert
    AppPolicy.create(title: 'Cancellation Policy',
                     description: ['When you cancel a call, the customer will receive a full refund'],
                     expert: true, individual: false, global: false, version: '1.0')
    # create call-rescheduling policy
    # for individual
    AppPolicy.create(title: 'Rescheduling Policy',
                     description: ['You may reschedule any time up to 24 hours before a call',
                                   'The reschedule request is subject to agreement by the expert',
                                   "If the expert does not agree to the reschedule request, the existing time of the call doesn’t change",
                                   'There is no limit on the number of reschedule requests you can send',
                                   'If your request has not been answered within 24 hours of the scheduled start time, the call time is set to the originally agreed upon time'],
                     expert: false, individual: true, global: false, version: '1.0')
    # for expert
    AppPolicy.create(title: 'Rescheduling Policy',
                     description: ['You may reschedule any time up to 24 hours before a call',
                                   'If the user accepts the reschedule request the call time will change to the new time',
                                   'If the user declines your request, the call is canceled and the user receives a full refund',
                                   'If your request has not been answered within 24 hours of the scheduled start time, the call time is set to the originally agreed upon time, but you still have the option to cancel the call'],
                     expert: true, individual: false, global: false, version: '1.0')
    # create call suggest new time policy
    AppPolicy.create(title: 'Suggest New Time Policy',
                     description: ['The user will receive a notification informing them you have suggested a new time for the call',
                                   'If the user accepts your suggested time, the time of the call will update automatically',
                                   'If the user declines the suggested time, the call will be declined'],
                     expert: true, individual: false, global: false, version: '1.0')

    # Scheduling Policy for individual
    AppPolicy.create(title: 'Scheduling Policy',
                     description: ['The expert has 5 days to accept your booking request call',
                                   'If you are booking a call that is less than 5 days away the expert has up to 24 hours in advance of the call to accept',
                                   'An authorization on your form of payment will be made when you send a booking request',
                                   'If a call request expires, or is declined, the authorization will be released',
                                   'If the expert accepts your call request, the authorized funds will transfer'],
                     expert: false, individual: true, global: false, version: '1.0')
  end
end
