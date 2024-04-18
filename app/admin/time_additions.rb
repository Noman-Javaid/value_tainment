ActiveAdmin.register TimeAddition do
  menu priority: 5
  config.batch_actions = false
  actions :all, except: [:destroy, :edit, :new]

  permit_params :status

  action_item :set_as_refunded, only: :show do
    link_to 'Make refund', set_as_refunded_admin_time_addition_path(resource), method: :patch if resource.confirmed?
  end

  index do
    selectable_column
    id_column
    column :expert_call
    column :status
    column 'Duration (min)' do |time_addition|
      (time_addition.duration / 60) if time_addition.duration
    end
    column 'Rate (USD)', &:rate
    column :payment_id
    column :payment_status
    column :created_at
    actions
  end

  show :title => proc {|time_addition| "Time Addition - (#{time_addition.status})" } do
    attributes_table do
      row :expert_call
      row :duration do |time_addition|
        (time_addition.duration / 60) if time_addition.duration
      end
      row :rate
      row :status
      row('Payment Intent Stripe ID') do |r|
        if r.payment_id
          link_to r.payment_id,
                  "https://dashboard.stripe.com/payments/#{r.payment_id}",
                  target: '_blank', rel: 'noopener'
        end
      end
      row :payment_status
      row :created_at
    end

    panel 'Alerts' do
      table_for(time_addition.alerts) do |t|
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
      attributes_table_for(time_addition.refunds) do
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
        row :amount
        row('Stripe Metadata', &:refund_metadata)
        row :created_at
      end
    end

    panel 'Associated Transfers' do
      if time_addition.expert_call.transfers.any?
        h3 'The transfer of this Time Addition is included as part of '\
        "the Expert Call #{link_to time_addition.expert_call.title, admin_expert_call_path(time_addition.expert_call)}".html_safe # rubocop:disable Rails/OutputSafety
      end
      attributes_table_for(time_addition.expert_call.transfers) do
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
        row :amount
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
      return redirect_to resource_path, alert: 'The Time Addition could not be refunded.'
    end
    redirect_to resource_path, notice: 'The Time Addition has been refunded.'
  end
end
