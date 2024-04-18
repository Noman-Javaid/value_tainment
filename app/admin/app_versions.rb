ActiveAdmin.register AppVersion do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  config.batch_actions = false
  permit_params :platform, :version, :force_update, :supported, :is_latest, :release_date, :support_ends_on
  #
  # or
  #
=begin
   permit_params do
     permitted = [:platform, :version, :force_update, :supported, :is_latest, :release_date, :support_ends_on]
     permitted << :other if params[:action] == 'create' && current_user.admin?
     permitted
   end
=end

  filter :platform
  filter :version


  index do
    selectable_column
    id_column
    column :platform
    column :version
    column :force_update
    column :supported
    column :is_latest
    column :release_date
    column :support_ends_on
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :platform, as: :select, collection: AppVersion.platforms.collect {|version| [version.last] }, include_blank: false
      f.input :version
      f.input :force_update
      f.input :supported, default: true
      f.input :is_latest
    end
    f.actions
  end
end
