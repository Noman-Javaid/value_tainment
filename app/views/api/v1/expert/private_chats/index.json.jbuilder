json.status :success
json.results @private_chats.total_count
json.total_pages @private_chats.total_pages
json.current_page @private_chats.current_page
json.next_page @private_chats.next_page
json.prev_page @private_chats.prev_page
json.has_more !@private_chats.last_page?
pending_earnings = current_user.expert.private_chats.pending.map(&:latest_message_price).sum
json.pending_earnings pending_earnings
json.total_pending_conversations current_user.expert.private_chats.pending.count
json.formatted_pending_earnings number_to_currency(pending_earnings, locale: :en, precision: 0)
json.data do
  json.private_chats @private_chats, partial: 'api/v1/expert/private_chats/private_chat', as: :private_chat
end
