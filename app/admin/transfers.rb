ActiveAdmin.register Transfer do
  menu priority: 7
  config.batch_actions = false
  actions :all, except: [:destroy, :edit, :new]

  index do
    selectable_column
    id_column
    column 'Name', :transferable
    column 'Interaction Type', :transferable_type
    column 'Tranfer ID Stripe' do |t|
      if t.transfer_id_ext
        link_to t.transfer_id_ext,
                "https://dashboard.stripe.com/connect/transfers/#{t.transfer_id_ext}",
                target: '_blank', rel: 'noopener'
      end
    end
    column 'Amount (USD)' do |transfer|
      (transfer.amount / Stripes::BaseService::USD_CURRENCY_FACTOR) if transfer.amount
    end
    column :reversed
    column :created_at

    actions
  end

  show do
    attributes_table do
      row :transferable_type
      row :transferable
      row :transfer_id_ext do |t|
        if t.transfer_id_ext
          link_to t.transfer_id_ext,
                  "https://dashboard.stripe.com/connect/transfers/#{t.transfer_id_ext}",
                  target: '_blank', rel: 'noopener'
        end
      end

      row('amount') do |t|
        if t.amount.present? && t.amount > 0
          t.amount / 100
        end
      end

      row :destination_account_id_ext do |t|
        if t.destination_account_id_ext
          link_to t.destination_account_id_ext,
                  "https://dashboard.stripe.com/connect/accounts/#{t.destination_account_id_ext}",
                  target: '_blank', rel: 'noopener'
        end
      end
      row :balance_transaction_id_ext
      row :destination_payment_id_ext_id_ext do |t|
        if t.destination_payment_id_ext
          link_to t.destination_payment_id_ext,
                  "https://dashboard.stripe.com/connect/accounts/#{t.destination_account_id_ext}/payments/#{t.destination_payment_id_ext}",
                  target: '_blank', rel: 'noopener'
        end
      end
      row :reversed
      row :transfer_metadata
      row :created_at
      row :updated_at
    end
  end
end
