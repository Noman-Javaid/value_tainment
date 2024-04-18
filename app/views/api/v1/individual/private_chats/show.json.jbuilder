json.status :success
json.private_chat @private_chat, partial: 'api/v1/individual/private_chats/private_chat', as: :private_chat
