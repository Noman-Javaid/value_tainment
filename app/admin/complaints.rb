ActiveAdmin.register Complaint do
  config.batch_actions = false
  permit_params :content, :status, :expert_id, :expert_interaction_id, :individual_id
  form partial: 'form'

  filter :status
  filter :expert_id
  filter :expert_interaction_id
  filter :individual_id

  index do
    selectable_column
    id_column
    column :content
    column :status
    column 'Interaction Type' do |c|
      c.expert_interaction&.interaction_type
    end
    column 'Interaction' do |c|
      case c.expert_interaction&.interaction_type
      when 'QuickQuestion'
        link = admin_quick_question_path(c.expert_interaction.interaction)
        link_to c.expert_interaction.interaction.question, link
      when 'ExpertCall'
        link = admin_expert_call_path(c.expert_interaction.interaction)
        link_to c.expert_interaction.interaction.title, link
      end
    end
    column :expert
    column 'Individual' do |t|
      link_to t.individual.name, admin_user_path(t.individual.user)
    end
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :individual do |complaint|
        link_to complaint.individual.user.name, admin_user_path(complaint.individual.user.id)
      end
      row :expert
      row :content
      row :status
      row :created_at
      row :updated_at
    end
    if complaint.expert_interaction
      if complaint.expert_interaction.interaction_type == 'QuickQuestion'
        panel 'Quick Question Information' do
          attributes_table_for(complaint.expert_interaction.interaction) do
            row :question
            row :description
            row :answer
            row :answer_date
            row :category
            row :status
            row :rate do |complaint|
              "#{complaint.expert_interaction.interaction.rate} USD"
            end
            row :attachment do |interaction|
              attachment_hash = interaction.attachment&.get_attachment_url
              if attachment_hash
                link_to 'link', attachment_hash[:url]
              else
                attachment_hash
              end
            end
            row('Payment Intent Stripe ID') do |r|
              if r.payment_id
                link_to r.payment_id,
                        "https://dashboard.stripe.com/payments/#{r.payment_id}",
                        target: '_blank', rel: 'noopener'
              end
            end
            row :payment_status
            row :refund_id
            row :stripe_payment_method_id
            row :created_at
            row :updated_at
          end
        end
      else
        panel 'Expert Call Information' do
          attributes_table_for(complaint.expert_interaction.interaction) do
            row :title
            row :description
            row :scheduled_call_duration
            row :scheduled_time_start
            row :scheduled_time_end
            row :guests_count
            row :rate do |complaint|
              "#{complaint.expert_interaction.interaction.rate} USD"
            end
            row :category
            row :call_status
            row :call_type
            row :call_time
            row :time_start
            row :time_end
            row :room_id
            row('Payment Intent Stripe ID') do |r|
              if r.payment_id
                link_to r.payment_id,
                        "https://dashboard.stripe.com/payments/#{r.payment_id}",
                        target: '_blank', rel: 'noopener'
              end
            end
            row :payment_status
            row :stripe_payment_method_id
            row :created_at
            row :updated_at
          end
        end
      end
    end
  end
end
