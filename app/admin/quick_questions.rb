include ActionView::Helpers::DateHelper # rubocop:todo Style/MixinUsage

ActiveAdmin.register QuickQuestion do
  menu priority: 4
  config.batch_actions = false
  actions :all, except: [:edit, :new]

  action_item :set_as_refunded, only: :show do
    link_to 'Make refund', set_as_refunded_admin_quick_question_path(resource), method: :patch if resource.answered? || resource.approved_complaint?
  end

  action_item :set_as_refunded, only: :show do
    if resource.answered? || resource.approved_complaint?
      link_to 'Make refund', set_as_refunded_admin_quick_question_path(resource), method: :patch
    end
  end

  index do
    selectable_column
    id_column
    column :question
    column :answer
    column :answer_date
    column 'Rate (USD)', &:rate
    column :status
    column :payment_status
    column :expert
    column 'Individual' do |q|
      link_to q.individual.name, admin_user_path(q.individual.user)
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :question
      row :description
      row :expert
      row 'Individual' do |e|
        link_to e.individual.name, admin_user_path(e.individual.user)
      end
      row :category
      row :answer_date
      row :answer
      row :status
      row :rate do |quick_question|
        "#{quick_question.rate} USD"
      end
      row('Payment Intent Stripe ID') do |r|
        if r.payment_id
          link_to r.payment_id,
                  "https://dashboard.stripe.com/payments/#{r.payment_id}",
                  target: '_blank', rel: 'noopener'
        end
      end
      row :payment_status
      row :response_time do |quick_question|
        distance_of_time_in_words(quick_question.response_time.hours)
      end
      row :stripe_payment_method_id
      row :created_at
    end

    panel 'Alerts' do
      table_for(quick_question.alerts) do |t|
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
      attributes_table_for(quick_question.refunds) do
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

    panel 'Transfers' do
      attributes_table_for(quick_question.transfers) do
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
      return redirect_to resource_path, alert: 'The Quick Question could not be refunded.'
    end
    redirect_to resource_path, notice: 'The Quick Question has been refunded.'
  end

  filter :expert_user_email, as: :string
  filter :expert_user_first_name, as: :string
  filter :expert_user_last_name, as: :string
  filter :individual_user_email, as: :string
  filter :individual_user_first_name, as: :string
  filter :individual_user_last_name, as: :string
  filter :category_name, as: :string
end
