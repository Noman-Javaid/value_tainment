ActiveAdmin.register ExpertCall do
  menu priority: 3
  config.batch_actions = false
  actions :all, except: [:destroy, :edit, :new]

  action_item :set_as_refunded, only: :show do
    link_to 'Make refund', set_as_refunded_admin_expert_call_path(resource), method: :patch if resource.finished? || resource.approved_complaint?
  end

  action_item :set_as_refunded, only: :show do
    if resource.finished? || resource.approved_complaint?
      link_to 'Make refund', set_as_refunded_admin_expert_call_path(resource), method: :patch
    end
  end

  index do
    selectable_column
    id_column
    column :title
    column :call_type
    column :expert
    column 'Individual' do |e|
      link_to e.individual.name, admin_user_path(e.individual.user)
    end
    column :call_status
    column 'Rate (USD)', &:rate
    column :scheduled_time_start
    column :scheduled_time_end
    column :time_start
    column :time_end
    column :payment_status
    column :created_at
    actions
  end

  show title: proc { |_expert_call| 'Expert Call' } do
    attributes_table do
      row :expert
      row 'Individual' do |e|
        link_to e.individual.name, admin_user_path(e.individual.user)
      end
      row :category
      row :call_type
      row :title
      row :description
      row :scheduled_time_start
      row :scheduled_time_end
      row :rate do |expert_call|
        "#{expert_call.rate} USD"
      end
      row :call_status
      row :time_start
      row :time_end
      row :room_id
      row('Payment Intent Stripe ID') do |r|
        if r.payment_id
          link_to r.payment_id,
                  "https://dashboard.stripe.com/payments/#{r.payment_id}",
                  target: '_blank', rel: 'noopener'
        end
      end
      row :payment_status
      row('Stripe Customer ID') do |expert_call|
        if expert_call.individual.stripe_customer_id
          link_to expert_call.individual.stripe_customer_id,
                  "https://dashboard.stripe.com/customers/#{expert_call.individual.stripe_customer_id}",
                  target: '_blank', rel: 'noopener'
        end
      end
      row :call_time do |expert_call|
        "#{expert_call.call_time / 60} mins"
      end
      row :stripe_payment_method_id
      row :scheduled_call_duration do |expert_call|
        "#{expert_call.scheduled_call_duration} mins"
      end
      row :created_at
    end

    panel 'Time Additions' do
      table_for(expert_call.time_additions) do |t|
        t.column(:id) do |time_addition|
          link_to(time_addition.id, admin_time_addition_path(time_addition))
        end
        t.column :expert_call
        t.column :rate
        t.column :duration do |time_addition|
          (time_addition.duration / 60) if time_addition.duration
        end
        t.column :status
        t.column :payment_id
        t.column :payment_status
        t.column :created_at
      end
    end

    panel 'Participant Events' do
      table_for(expert_call.participant_events) do |t|
        t.column(:id) do |participant_event|
          link_to(participant_event.id, admin_participant_event_path(participant_event))
        end
        t.column :event_name
        t.column :event_datetime
        t.column(:duration) { |participant_event| (participant_event.duration / 60.0).round(2) if participant_event.duration }
        t.column :expert
        t.column :initial
        t.column(:participant_id) { |event| event.participant.email }
        t.column :created_at
      end
    end

    panel 'Participants Duration In Call' do
      attributes_table_for(expert_call) do
        row 'Expert Duration In Call' do |expert_call|
          (expert_call.participant_events.disconnected.where(expert: true).sum(:duration) / 60.0).round(2)
        end
        row 'Individual Duration In Call' do |expert_call|
          (expert_call.participant_events.disconnected.where(expert: false).sum(:duration) / 60.0).round(2)
        end
      end
    end

    panel 'Alerts' do
      table_for(expert_call.alerts) do |t|
        t.column :id do |a|
          link_to a.id, admin_alert_path(a.id)
        end
        t.column :alert_type
        t.column 'Interaction', :alertable
        t.column 'Interaction Type', :alertable_type
        t.column :message
        t.column :created_at
      end
    end

    panel 'Refunds' do
      attributes_table_for(expert_call.refunds) do
        row('ID') { |r| link_to r.id, admin_refund_path(r.id) }
        row('Refund Stripe ID', &:refund_id_ext)
        row('Payment Intent Stripe ID') do |r|
          if r.payment_intent_id_ext
            link_to r.payment_intent_id_ext,
                    "https://dashboard.stripe.com/payments/#{r.payment_intent_id_ext}",
                    target: '_blank', rel: 'noopener'
          end
        end
        row :status
        row('amount') do |t|
          if t.amount.present? && t.amount > 0
            t.amount / 100
          end
        end
        row('Stripe Metadata', &:refund_metadata)
        row :created_at
      end
    end

    panel 'Transfers' do
      attributes_table_for(expert_call.transfers) do
        row('ID') { |t| link_to t.id, admin_transfer_path(t.id) }
        row('Transfer Stripe ID') do |t|
          if t.transfer_id_ext
            link_to t.transfer_id_ext,
                    "https://dashboard.stripe.com/connect/transfers/#{t.transfer_id_ext}",
                    target: '_blank', rel: 'noopener'
          end
        end
        row('Destination Account Stripe ID') do |t|
          if t.destination_account_id_ext
            link_to t.destination_account_id_ext,
                    "https://dashboard.stripe.com/connect/accounts/#{t.destination_account_id_ext}",
                    target: '_blank', rel: 'noopener'
          end
        end
        row('Destination Payment Stripe ID') do |t|
          if t.destination_payment_id_ext
            link_to t.destination_payment_id_ext,
                    "https://dashboard.stripe.com/connect/accounts/#{t.destination_account_id_ext}/payments/#{t.destination_payment_id_ext}",
                    target: '_blank', rel: 'noopener'
          end
        end
        row('Balance Transaction Stripe ID', &:balance_transaction_id_ext)
        row('amount') do |t|
          if t.amount.present? && t.amount > 0
            t.amount / 100
          end
        end
        row :reversed
        row('Stripe Metadata', &:transfer_metadata)
        row :created_at
      end
    end
  end

  member_action :set_as_refunded, method: :patch do
    begin
      resource.refund
      resource.save!
    rescue StandardError
      resource.unrefund!
      return redirect_to resource_path, alert: 'The Expert Call could not be refunded.'
    end
    redirect_to resource_path, notice: 'The Expert Call has been marked as refunded.'
  end

  filter :expert_user_email, as: :string
  filter :expert_user_first_name, as: :string
  filter :expert_user_last_name, as: :string
  filter :individual_user_email, as: :string
  filter :individual_user_first_name, as: :string
  filter :individual_user_last_name, as: :string
  filter :category_name, as: :string
end
