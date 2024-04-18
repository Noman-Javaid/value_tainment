ActiveAdmin.register Expert do
  menu label: 'Experts', priority: 2
  config.batch_actions = false
  config.sort_order = 'created_at_desc'

  actions :index, :show, :edit, :update
  permit_params :status, :featured, :payout_percentage

  scope :all, default: true
  scope('Featured Expert') { |_scope| Expert.where(featured: true) }
  index do
    selectable_column
    id_column
    column :name do |expert|
      expert.user.name
    end
    column :email do |expert|
      expert.user.email
    end
    column :active do |expert|
      expert.user.active
    end
    column :status
    column :featured
    column :updated_at
    column 'Interactions' do |expert|
      html = "<span>Questions: #{expert.quick_questions.count}</span></br>"
      html += "<span>Calls: #{expert.expert_calls.count}</span></br>"
      html += "<span>Calls(1-1): #{expert.expert_calls.where(call_type: ExpertCall::CALL_TYPE_ONE_TO_ONE).count}</span></br>"
      html += "<span>Calls(1-5): #{expert.expert_calls.where(call_type: ExpertCall::CALL_TYPE_ONE_TO_FIVE).count}</span>"
      raw html # rubocop:todo Rails/OutputSafety
    end
    actions
  end

  action_item :verify, only: :show do
    link_to 'Verify', verify_admin_expert_path(expert), method: :patch if expert.pending?
  end
  action_item :reject, only: :show do
    link_to 'Reject', reject_admin_expert_path(expert), method: :patch if expert.pending?
  end

  show title: proc { |expert| "Expert - #{expert.user.name} (#{expert.status})" } do
    if expert.pending?
      div do
        div 'This Expert is not yet verified.'
      end
    end
    attributes_table do
      row :profile_picture do |expert|
        image_tag expert.url_picture, size: '200x200' if expert.url_picture
      end
      row :name do |expert|
        expert.user.name
      end
      row :email do |expert|
        expert.user.email
      end
      row :status
      row :featured
      row :payout_percentage
      row :active do |expert|
        expert.user.active
      end
      row :created_at do |expert|
        expert.user.created_at
      end
      row :date_of_birth do |expert|
        expert.user.date_of_birth
      end
      row :gender do |expert|
        expert.user.gender
      end
      row :phone_number do |expert|
        expert.user.phone_number
      end
      row :country do |expert|
        expert.user.country
      end
      row :city do |expert|
        expert.user.city
      end
      row :zip_code do |expert|
        expert.user.zip_code
      end
      row :categories do |expert|
        expert.categories.pluck(:name).each do |category_name|
          status_tag category_name, class: 'no'
        end and nil
      end
      row :created_at
    end

    attributes_table title: 'Extra information' do
      row :stripe_account_id do |expert|
        if expert.stripe_account_id
          link_to expert.stripe_account_id,
                  "https://dashboard.stripe.com/connect/accounts/#{expert.stripe_account_id}",
                  target: '_blank', rel: 'noopener'
        end
      end
      row :stripe_account_set
      row :can_receive_stripe_transfers
      row :biography
      row :website_url
      row :twitter_url
      row :instagram_url
      row :linkedin_url
      row :quick_question_rate do |expert|
        "#{expert.quick_question_rate} USD"
      end
      row :one_to_one_video_call_rate do |expert|
        "#{expert.one_to_one_video_call_rate} USD"
      end
      row :one_to_five_video_call_rate do |expert|
        "#{expert.one_to_five_video_call_rate} USD"
      end
      row :extra_user_rate do |expert|
        "#{expert.extra_user_rate} USD"
      end
    end

    quick_questions_list = expert.quick_questions
    expert_call_list = expert.expert_calls
    expert_call_1_1_list = expert_call_list.where(call_type: ExpertCall::CALL_TYPE_ONE_TO_ONE)
    expert_call_1_5_list = expert_call_list.where(call_type: ExpertCall::CALL_TYPE_ONE_TO_FIVE)

    attributes_table title: 'Interactions' do
      interaction_class = 'interaction_list'
      question_button_id = 'question_interaction_button'
      expert_call_button_id = 'expert_call_interaction_button'
      expert_call_1_1_button_id = 'expert_call_1_1_interaction_button'
      expert_call_1_5_button_id = 'expert_call_1_5_interaction_button'
      questions = "<span>#{quick_questions_list.count}</span><button type='button' id='#{question_button_id}' class='#{interaction_class}'>Show</button>"
      expert_calls = "<span>#{expert_call_list.count}</span><button type='button' id='#{expert_call_button_id}' class='#{interaction_class}'>Show</button>"
      # rubocop:todo Naming/VariableNumber
      expert_calls_1_1 = "<span>#{expert_call_1_1_list.count}</span><button type='button' id='#{expert_call_1_1_button_id}' class='#{interaction_class}'>Show</button>"
      # rubocop:enable Naming/VariableNumber
      # rubocop:todo Naming/VariableNumber
      expert_calls_1_5 = "<span>#{expert_call_1_5_list.count}</span><button type='button' id='#{expert_call_1_5_button_id}' class='#{interaction_class}'>Show</button>"
      # rubocop:enable Naming/VariableNumber
      row :questions do
        raw questions # rubocop:todo Rails/OutputSafety
      end
      row :calls do
        raw expert_calls # rubocop:todo Rails/OutputSafety
      end
      row 'calls 1-1' do
        raw expert_calls_1_1 # rubocop:todo Rails/OutputSafety
      end
      row 'calls 1-5' do
        raw expert_calls_1_5 # rubocop:todo Rails/OutputSafety
      end
    end

    panel 'Quick Question Interactions', id: 'questions_interactions',
                                         class: 'expert_q_i',
                                         style: 'display: none;' do
      table_for(quick_questions_list) do |t|
        t.column(:id) { |question| link_to(question.id, admin_quick_question_path(question)) }
        t.column :question
        t.column :payment_id do |question|
          if question.payment_id
            link_to(
              question.payment_id,
              "https://dashboard.stripe.com/payments/#{question.payment_id}",
              target: '_blank', rel: 'noopener'
            )
          end
        end
        t.column :payment_status
      end
    end

    panel 'Calls Interactions', id: 'expert_calls_interactions', class: 'expert_c_i',
                                style: 'display: none;' do
      table_for(expert_call_list) do |t|
        t.column(:id) { |call| link_to(call.id, admin_expert_call_path(call)) }
        t.column :title
        t.column :payment_id do |call|
          if call.payment_id
            link_to(
              call.payment_id,
              "https://dashboard.stripe.com/payments/#{call.payment_id}",
              target: '_blank', rel: 'noopener'
            )
          end
        end
        t.column :payment_status
      end
    end
    panel 'Calls 1-1 Interactions', id: 'expert_calls_interactions_1_1',
                                    class: 'expert_q_i_1_1',
                                    style: 'display: none;' do
      table_for(expert_call_1_1_list) do |t|
        t.column(:id) { |call| link_to(call.id, admin_expert_call_path(call)) }
        t.column :title
        t.column :payment_id do |call|
          if call.payment_id
            link_to(
              call.payment_id,
              "https://dashboard.stripe.com/payments/#{call.payment_id}",
              target: '_blank', rel: 'noopener'
            )
          end
        end
        t.column :payment_status
      end
    end

    panel 'Calls 1-5 Interactions', id: 'expert_calls_interactions_1_5',
                                    class: 'expert_q_i_1_5',
                                    style: 'display: none;' do
      table_for(expert_call_1_5_list) do |t|
        t.column(:id) { |call| link_to(call.id, admin_expert_call_path(call)) }
        t.column :title
        t.column :payment_id do |call|
          if call.payment_id
            link_to(
              call.payment_id,
              "https://dashboard.stripe.com/payments/#{call.payment_id}",
              target: '_blank', rel: 'noopener'
            )
          end
        end
        t.column :payment_status
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :status
      f.input :featured
      f.input :payout_percentage, input_html: { min: 0, max: 100, style: 'width: 100px' }
    end

    f.actions
  end

  member_action :verify, method: :patch do
    resource.verify!
    redirect_to resource_path, notice: 'The Expert has been marked as verified.'
  end

  member_action :reject, method: :patch do
    resource.reject!
    redirect_to resource_path, notice: 'The Expert has been marked as rejected.'
  end

  filter :user_email, as: :string
  filter :user_first_name, as: :string
  filter :user_last_name, as: :string
  filter :user_active, as: :boolean
  filter :created_at
  filter :status, as: :select, collection: proc { Expert.statuses }
end
