
class PrivateChatCommands::ReadMessage
  prepend SimpleCommand

  def initialize(private_chat_id, reader)
    @private_chat_id = private_chat_id
    @reader = reader
  end

  def call
    unread_messages = private_chat.unread_messages(@reader)
    if unread_messages.present?
      unread_messages.each do |message|
        MessageRead.create(message: message, reader: @reader)
      end
    end
  end

  def private_chat
    @private_chat ||= PrivateChat.find @private_chat_id
  end
end
