ActiveAdmin.register Transaction do
  menu priority: 9
  config.batch_actions = false
  actions :all, except: [:destroy, :edit, :new]

  index title: 'Transaction History' do
    selectable_column
    id_column
    column 'Individual' do |t|
      link_to t.individual.name, admin_user_path(t.individual.user)
    end
    column :expert
    column :time_addition
    column 'Amount (USD)' do |transaction|
      (transaction.amount / Stripes::BaseService::USD_CURRENCY_FACTOR) if transaction.amount
    end
    column :charge_type
    column :stripe_transaction_id
    column :created_at
    actions
  end

  show title: proc { |transaction| "Transaction History ##{transaction.id}" } do
    attributes_table do
      row 'Individual' do |t|
        link_to t.individual.name, admin_user_path(t.individual.user)
      end
      row :expert
      row :time_addition
      row :amount do |transaction|
        (transaction.amount / Stripes::BaseService::USD_CURRENCY_FACTOR) if transaction.amount
      end
      row :charge_type
      row :stripe_transaction_id
      row :created_at
    end
  end

  filter :stripe_transaction_id
  filter :charge_type
end
