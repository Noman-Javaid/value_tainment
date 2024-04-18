ActiveAdmin.register Territory do
  config.batch_actions = false
  permit_params :name, :alpha2_code, :phone_code, :active, :flag

  filter :name
  filter :alpha2_code
  filter :active
  filter :phone_code

  index do
    selectable_column
    id_column
    column :name
    column :alpha2_code
    column :phone_code
    column :active
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :alpha2_code
      f.input :phone_code
      f.input :active
      f.input :flag, as: :file
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :alpha2_code
      row :phone_code
      row :active
      row :flag do |territory|
        image_tag territory.flag_url, size: '150x100' if territory.flag_url
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end
end
