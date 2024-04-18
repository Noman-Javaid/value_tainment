json.status :success
json.results @private_chats.total_count
json.total_pages @private_chats.total_pages
json.current_page @private_chats.current_page
json.next_page @private_chats.next_page
json.prev_page @private_chats.prev_page
json.has_more !@private_chats.last_page?
json.data do
  json.private_chats @private_chats, partial: 'api/v1/individual/private_chats/private_chat', as: :private_chat
end
