class Api::V1::Expert::PrivateChatsController < Api::V1::Expert::ExpertCallsController
  before_action :set_private_chat, only: [:message]
  def message
      create_message = PrivateChatCommands::CreateMessage.call(@expert, params[:id],
                                                       message_params[:message], 'sent', 'text', nil)
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
        render json: { success: true, message: I18n.t('api.message.create.expert_reply') }
      else
        json_error_response(create_message.errors[:error_message].join(','), :bad_request)
      end
  end

  def read_messages
    read_message = PrivateChatCommands::ReadMessage.call(params[:id], @expert)
    if read_message.success?
      render json: { success: true, message: I18n.t('api.message.create.marked_as_read') }
    else
      json_error_response(read_message.errors[:error_message].join(','), :bad_request)
    end
  end

  def index
    if params[:status] == 'pending'
      results = @expert.private_chats.pending
    elsif params[:status] == 'completed'
      results = @expert.private_chats.completed_chats
    else
      results = @expert.private_chats
    end
    @private_chats = results.page(params[:page]).per(params[:per_page])
  end

  def show
    @private_chat = @expert.private_chats.find(params[:id])
  end

  private

  def message_params
    params.require(:private_chat).permit(:message)
  end

  def set_private_chat
    @private_chat ||= @expert.private_chats.find(params[:id])
  end

end
