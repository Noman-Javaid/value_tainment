ActiveAdmin.register User do
  menu priority: 1
  config.batch_actions = false
  config.sort_order = 'created_at_desc'

  scope('Individual', default: true) { |_scope| User.by_role('individual') }
  scope('Admin') { User.by_role('admin') }
  scope('Default') { User.by_role('default') }
  scope('Email Verified') { |_scope| User.by_role('individual').where(account_verified: true) }
  scope('Pending To Delete') { |_scope| User.by_role('individual').where(pending_to_delete: true) }
  scope('With Both Profiles') { |_scope| User.joins(:individual, :expert).where.not(individual: nil, expert: nil) }
  scope('Email Verified') { |scope| User.where(account_verified: true) }

  # actions :index, :show, :edit, :update
  # permit_params :active
  permit_params :first_name, :last_name, :email, :password, :password_confirmation,
                :admin, :active, :date_of_birth, :gender, :phone_number, :phone, :country_code, :country, :city,
                :zip_code, :account_verified, :selectable_column, :picture,
                expert_attributes: [
                  :id,
                  :featured,
                  :stripe_account_id,
                  :stripe_account_set,
                  :can_receive_stripe_transfers,
                  :biography,
                  :website_url,
                  :linkedin_url,
                  :twitter_url,
                  :instagram_url,
                  :quick_question_rate,
                  :one_to_one_video_call_rate,
                  :one_to_five_video_call_rate,
                  :extra_user_rate
                ],
                individual_attributes: [
                  :id,
                  :stripe_customer_id,
                  :has_stripe_payment_method,
                  :username
                ]

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :active
    column 'Email Verified', :account_verified
    column :pending_to_delete
    column :created_at
    column 'Email Verified', :account_verified
    actions
  end

  show do
    h3 user.name
    attributes_table do
      row :name
      row :email
      row :current_role
      row :active
      row :date_of_birth
      row :gender
      row :phone_number
      row :country
      row :city
      row :zip_code
      row 'Email Verified' do
        user.account_verified
      end
      row :pending_to_delete
      row :profile_picture do |user|
        image_tag user.url_picture, size: '200x200' if user.url_picture
      end
      row :account_deletion_requested_at
      row :created_at
    end
    if user.individual?
      panel 'Individual user information' do
        attributes_table_for(user.individual) do
          row :stripe_customer_id do |user|
            if user.stripe_customer_id
              link_to user.stripe_customer_id,
                      "https://dashboard.stripe.com/customers/#{user.stripe_customer_id}",
                      target: '_blank', rel: 'noopener'
            end
          end
          row :has_stripe_payment_method
          row :username
          row :ready_for_deletion
        end
      end
    end
    if user.expert?
      panel 'Expert information' do
        attributes_table_for(user.expert) do
          row :featured
          row :stripe_account_id do
            if user.expert.stripe_account_id
              link_to user.expert.stripe_account_id,
                      "https://dashboard.stripe.com/connect/accounts/#{user.expert.stripe_account_id}",
                      target: '_blank', rel: 'noopener'
            end
          end
          row :stripe_account_set
          row :can_receive_stripe_transfers
          row :biography
          row :website_url
          row :linkedin_url
          row :twitter_url
          row :instagram_url
          row :quick_question_rate
          row :one_to_one_video_call_rate
          row :one_to_five_video_call_rate
          row :extra_user_rate
          row :ready_for_deletion
        end
      end
    end
  end

  filter :email
  filter :first_name
  filter :last_name
  filter :created_at
  filter :by_role, as: :select, collection: User.roles, filters: [:eq]

  form do |f|
    f.inputs do
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :password
      f.input :password_confirmation
      f.input :date_of_birth, as: :datepicker,
                              datepicker_options: {
                                year_range: '-100:+0',
                                change_month: true,
                                change_year: true
                              }
      f.input :gender
      f.input :phone_number
      f.input :country, as: :string
      f.input :city
      f.input :zip_code
      f.input :picture, as: :file
      if params[:role] == 'admin' || user.admin?
        f.input :admin, input_html: { disabled: true, checked: true }
        f.input :admin, as: :hidden, input_html: { value: true }
      end
      f.input :account_verified, label: 'Email verified'
      f.input :active
      if user.expert?
        f.has_many :expert, allow_destroy: false, new_record: false, remove_record: false do |a|
          a.input :id, as: :hidden if user.persisted?
          a.input :featured
          a.input :stripe_account_id
          a.input :stripe_account_set
          a.input :can_receive_stripe_transfers
          a.input :biography
          a.input :website_url
          a.input :linkedin_url
          a.input :twitter_url
          a.input :instagram_url
          a.input :quick_question_rate
          a.input :one_to_one_video_call_rate
          a.input :one_to_five_video_call_rate
          a.input :extra_user_rate
        end
      end
      if user.individual?
        f.has_many :individual, allow_destroy: false, new_record: false, remove_record: false do |a|
          a.input :id, as: :hidden if user.persisted?
          a.input :stripe_customer_id
          a.input :has_stripe_payment_method
          a.input :username
        end
      end
    end
    f.actions
  end

  controller do
    def update
      %w[password password_confirmation].each { |p| params[:user].delete(p) } if params[:user][:password].blank?

      super
    end

    def new
      build_resource
      if params[:role] == 'expert'
        resource.build_expert
        resource.role = 'expert'
        return
      end

      return if params[:role] == 'admin'

      resource.build_individual
      resource.role = 'individual'
    end
  end

  action_item :new_admin, only: :index do
    link_to 'New Admin', new_resource_path(role: :admin)
  end
  action_item :new_admin, only: :index do
    link_to 'New Expert', new_resource_path(role: :expert)
  end
end
