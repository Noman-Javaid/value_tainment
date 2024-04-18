# app/commands/create_private_chat_command.rb

class Individual::PrivateChatCommands::Create
  prepend SimpleCommand

  def initialize(created_by, name, description = nil, short_description = nil, status = 'pending', users_list = [], expert_id, individual_id)
    @created_by = created_by
    @name = name
    @description = description
    @short_description = short_description
    @status = status
    @users_list = users_list
    @expert_id = expert_id
    @individual_id = individual_id
  end

  def call
    (errors.add :error_message, I18n.t('api.private_chat.create.errors.unauthorized')).then { return } unless @created_by.is_a? Individual

    (errors.add :error_message, I18n.t('api.private_chat.create.errors.empty_users_list')).then { return } if @users_list.blank?

    private_chat = PrivateChat.find_by(expert_id: @expert_id, individual_id: @individual_id)

    if private_chat.present?
      private_chat
    else
      private_chat = PrivateChat.new(
        created_by: @created_by,
        name: @name,
        description: @description,
        short_description: @short_description,
        status: @status,
        users_list: @users_list,
        expert_id: @expert_id,
        individual_id: @individual_id
      )

      if private_chat.save
        private_chat
      else
        errors.add :error_message, private_chat.errors.messages.join(', ')
        nil
      end
    end
  end
end
