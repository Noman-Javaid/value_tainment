ActiveAdmin.register Alert do
  menu priority: 9
  config.batch_actions = false
  actions :all, except: [:destroy, :edit, :new]

  scope :all, default: true
  scope('Refunds') { Alert.where(alert_type: :refund) }
  scope('Transfers') { Alert.where(alert_type: :transfer) }
  scope('Pending') { Alert.where(status: :pending)}
  scope('Under Investigation') { Alert.where(status: :in_progress)}
  scope('Resolved') { Alert.where(status: :resolved)}

  member_action :review, method: :patch do
    resource.process! unless resource.in_progress?

    redirect_to resource_path, notice: 'Alert marked as under investigation.'
  end

  member_action :complete, method: :patch do
    resource.resolve! unless resource.resolved?

    redirect_to resource_path, notice: 'Alert marked as completed.'
  end

  action_item :review, only: :show, if: proc { resource.pending? } do
    link_to 'Mark as Under Investigation', review_admin_alert_path(resource), method: :patch
  end

  action_item :finish, only: :show, if: proc { !resource.resolved? } do
    link_to 'Mark as Completed', complete_admin_alert_path(resource), method: :patch
  end

  index do
    selectable_column
    id_column
    column :alert_type
    column 'Interaction', :alertable
    column 'Interaction Type', :alertable_type
    column :message
    column :status
    column :created_at

    actions
  end
end
