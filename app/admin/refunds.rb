ActiveAdmin.register Refund do
  menu priority: 6
  config.batch_actions = false
  actions :all, except: [:destroy, :edit, :new]

  index do
    selectable_column
    id_column
    column 'Name', :refundable
    column 'Interaction Type', :refundable_type
    column 'Refund ID Stripe', :refund_id_ext
    column 'Amount (USD)' do |refund|
      (refund.amount / Stripes::BaseService::USD_CURRENCY_FACTOR) if refund.amount
    end
    column :status
    column :created_at

    actions
  end

  show do
    attributes_table do
      row :refundable_type
      row :refundable
      row :payment_intent_id_ext do |r|
        if r.payment_intent_id_ext
          link_to r.payment_intent_id_ext,
                  "https://dashboard.stripe.com/payments/#{r.payment_intent_id_ext}",
                  target: '_blank', rel: 'noopener'
        end
      end
      row :refund_id_ext
      row :amount
      row :status
      row :refund_metadata
      row :created_at
      row :updated_at
    end
  end
end
