ActiveAdmin.register Category do
  config.batch_actions = false
  permit_params :name, :description

  filter :name
  filter :description

  index do
    selectable_column
    id_column
    column :name
    column :description
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :description
    end
    f.actions
  end
end
