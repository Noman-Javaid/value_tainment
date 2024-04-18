json.extract! message,
              :id,
               :text,
               :private_chat_id,
               :sender_id,
               :content_type,
               :answer_type,
               :attachment_id,
               :status
json.sent message.sent_at(for_user: current_user)
json.expiration_status message.expiration_status(for_user: @individual)
json.amount message.price
json.has_read message.read_by_user?(@individual)
json.formatted_amount message.price(formatted: true)
if message.content_type == 'file' && message.attachment.present? && message.attachment.in_bucket? && message.attachment.present?
  json.attachment do
    json.extract! message.attachment.get_attachment_url, :url, :headers
    json.file_type message.attachment.file_type_extension
    json.file_size message.attachment.file_size_description
    json.file_name message.attachment.file_name
  end
end