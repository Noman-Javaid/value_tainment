class Api::V1::Individual::PrivateChatsController < Api::V1::Individual::IndividualsController

  def create
    ActiveRecord::Base.transaction do
      # create private chat
      create_private_chat = Individual::PrivateChatCommands::Create.call(@individual,
                                                                         Faker::Fantasy::Tolkien.unique.character,
                                                                         nil,
                                                                         nil,
                                                                         'pending',
                                                                         [private_chat_params[:expert_id], @individual.id],
                                                                         private_chat_params[:expert_id],
                                                                         @individual.id)

      if create_private_chat.success?
        created_chat = create_private_chat.result

        # create message
        create_message = PrivateChatCommands::CreateMessage.call(@individual,
                                                                 created_chat.id,
                                                                 message_params[:message],
                                                                 'sent',
                                                                 'text',
                                                                 nil,
                                                                 message_params[:answer_type])
        raise StandardError.new(create_message.errors[:error_message].join(", ")) if create_message.failure?

        # create payment object
        message = create_message.result
        create_payment = PaymentCommands::Create.call(message, payment_params[:stripe_payment_method_id], message.rate, 'USD')
        raise StandardError.new(create_payment.errors[:error_message].join(", ")) if create_payment.failure?

        payment = create_payment.result
        # create payment intent on stripe
        create_payment_intent = PaymentCommands::CreatePaymentIntent.call(payment)
        raise StandardError.new(create_payment_intent.errors[:error_message].join(", ")) if create_payment_intent.failure?

        payment_intent = create_payment_intent.result
        @client_secret = payment_intent[:client_secret]
        # create transaction
        Transactions::Create.call(message, payment.reload, false)

        render json: { success: true, message: I18n.t('api.message.create.successful'), client_secret: @client_secret, private_chat_id: created_chat.id }
      else
        json_error_response(create_private_chat.errors[:error_message].join(','), :bad_request)
      end
    end
  rescue => e
    json_error_response(e.message, :bad_request)
  end

  def index
    @private_chats = @individual.private_chats
                                .page(params[:page])
                                .per(params[:per_page])
  end

  def show
    @private_chat = @individual.private_chats.find(params[:private_chat_id])
  end

  def read_messages
    read_message = PrivateChatCommands::ReadMessage.call(params[:private_chat_id], @individual)
    if read_message.success?
      render json: { success: true, message: I18n.t('api.message.create.marked_as_read') }
    else
      json_error_response(read_message.errors[:error_message].join(','), :bad_request)
    end
  end

  private

  def private_chat_params
    params.require(:private_chat).permit(:expert_id)
  end

  def message_params
    params.require(:private_chat).permit(:message, :answer_type)
  end

  def payment_params
    params.require(:private_chat).permit(:stripe_payment_method_id)
  end

end
