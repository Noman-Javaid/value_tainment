# app/commands/create_message_command.rb

class PrivateChatCommands::CreateMessage
  prepend SimpleCommand

  def initialize(sender, private_chat_id, text, status = 'sent', content_type = 'text', attachment_id = nil, answer_type = nil)
    @sender = sender
    @sender_type = sender.class.to_s
    @sender_id = sender.id
    @private_chat_id = private_chat_id
    @text = text
    @status = status
    @content_type = content_type
    @attachment_id = attachment_id
    @answer_type = answer_type
  end

  def call
    validate_private_chat && validate_sender

    return if errors.present?

    message = Message.new(
      sender_type: @sender_type,
      sender_id: @sender_id,
      private_chat_id: @private_chat_id,
      text: @text,
      status: @status,
      content_type: @content_type,
      attachment_id: @attachment_id,
      answer_type: @answer_type
    )

    if message.save
      message
    else
      errors.add :error_message, message.errors.messages.join(', ')
      nil
    end
  end

  private

  def validate_private_chat
    @private_chat = PrivateChat.find_by(id: @private_chat_id)

    unless @private_chat
      errors.add(:error_message, I18n.t('api.message.create.errors.invalid_private_chat'))
      return false
    end

    unless @private_chat.users_list.include?(@sender_id)
      errors.add(:error_message, I18n.t('api.message.create.errors.unauthorized_sender'))
      return false
    end

    true
  end

  def validate_sender
    case @sender_type
    when 'Expert'
      @sender = Expert.find_by(id: @sender_id)
    when 'Individual'
      @sender = Individual.find_by(id: @sender_id)
      unless can_send_message?
        errors.add(:error_message, I18n.t('api.message.create.errors.already_pending_question'))
        return false
      end
    else
      errors.add(:error_message, I18n.t('api.message.create.errors.invalid_sender_type'))
      return false
    end

    unless @sender
      errors.add(:error_message, I18n.t('api.message.create.errors.invalid_sender_type'))
      return false
    end

    true
  end

  def can_send_message?
    return false if @private_chat.messages_sent_by_user(@sender.id).status_sent.present?

    true
  end
end
