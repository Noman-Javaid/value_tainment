ActiveAdmin.register Reminder do
  config.batch_actions = false
  permit_params :timer, :detail, :active

  filter :timer
  filter :detail
  filter :active

  index do
    selectable_column
    id_column
    column :timer
    column :detail
    column :active
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :timer
      f.input :detail
      f.input :active
    end
    f.actions
  end
end
