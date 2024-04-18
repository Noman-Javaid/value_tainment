class Api::V1::Expert::PrivateChats::AttachmentsController <
  Api::V1::Expert::PrivateChatsController
  before_action :set_private_chat, only: %i[show create update]
  before_action :set_attachment, only: %i[show update]

  def create
    create_message = PrivateChatCommands::CreateMessage.call(@expert, params[:private_chat_id],
                                                             get_attachment_file_message(attachment_params[:file_type]), 'pending', 'file', nil)
    if create_message.success?
      @private_chat.answered!
      # update the individual message as answered
      pending_question = @private_chat.last_pending_message_from_individual
      if pending_question.present?
        Rails.logger.info("Updating the question = #{pending_question.id} as answered")
        pending_question.status_complete!

        Rails.logger.info("Capturing the payment for the message : #{pending_question.id}")
        PaymentCommands::CapturePayment.call(pending_question.payment)
      end
      created_message = create_message.result
      @attachment = created_message.create_attachment!(attachment_params)
      @attachment.generate_presigned_url
      created_message.update!(attachment_id: @attachment.id)
      render_show_attachment
    else
      json_error_response(create_message.errors[:error_message].join(','), :bad_request)
    end

  end

  def show
    raise ActiveRecord::RecordNotFound unless @attachment

    @attachment.get_attachment_url
    render_show_attachment
  end

  def update
    @attachment.update!(update_attachment_params)
    @attachment.get_attachment_url
    render_show_attachment
  end

  private

  def attachment_params
    params.require(:attachment).permit(:file_name, :file_type, :file_size)
  end

  def update_attachment_params
    params.require(:attachment).require(:in_bucket)
    params.require(:attachment).permit(:in_bucket)
  end

  def set_private_chat
    @private_chat = @expert.private_chats.find(params[:private_chat_id])
  end

  def set_attachment
    @attachment = @private_chat.messages.find(params[:attachment][:message_id]).attachment
  end

  def render_show_attachment
    render 'api/v1/expert/private_chats/attachment/show'
  end

  def get_attachment_file_message(file_type)
    video_file_types = %w[video/mp4 video/avi video/mov video/wmv video/flv video/mpeg video/quicktime]

    if video_file_types.include?(file_type)
      'Video answer received.'
    else
      'New attachment received.'
    end
  end

end
