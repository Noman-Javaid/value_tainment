json.extract! private_chat,
              :id,
              :expert_id,
              :individual_id,
              :name,
              :users_list,
              :status,
              :updated_at,
              :created_at
json.status_description private_chat.status_description(for_user: @expert)
json.answer_type private_chat.latest_answer_type
json.amount private_chat.latest_message_price
json.formatted_amount private_chat.latest_message_price(formatted: true)
json.has_new_message private_chat.has_new_message_for_user?(@expert)
json.un_read_messages_count private_chat.unread_message_count_for_user(@expert)
json.messages private_chat.messages, partial: 'api/v1/expert/messages/show_message', as: :message
json.expert private_chat.expert, partial: 'api/v1/expert/expert', as: :expert
json.individual private_chat.individual, partial: 'api/v1/individual/individual', as: :individual

