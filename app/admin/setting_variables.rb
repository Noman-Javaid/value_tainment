ActiveAdmin.register SettingVariable do
  config.batch_actions = false
  actions :all, except: [:destroy, :new]
  permit_params :question_response_time_in_days

  filter :question_response_time_in_days

  index do
    selectable_column
    id_column
    column :question_response_time_in_days
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :question_response_time_in_days
    end
    f.actions
  end
end
