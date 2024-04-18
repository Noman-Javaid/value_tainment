ActiveAdmin.register AccountDeletionFollowUp do
  config.batch_actions = false
  actions :all, except: [:destroy, :new]
  permit_params :user_id, :notes, :required_for_individual, :required_for_expert, :status

  filter :required_for_individual
  filter :required_for_expert

  index do
    selectable_column
    id_column
    column :user_id
    column :required_for_individual
    column :required_for_expert
    column :status
    column :notes
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :required_for_individual
      f.input :required_for_expert
      f.input :status
      f.input :notes
    end
    f.actions
  end
end
