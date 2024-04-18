class Api::V1::Individual::ExpertCallsController < Api::V1::Individual::IndividualsController
  def create
    @expert = Expert.find(expert_call_params[:expert_id])
    payment = nil
    ActiveRecord::Base.transaction do
      @expert_call = @individual.expert_calls.create!(expert_call_params)
      payment = Stripes::Payments::InteractionPaymentHandler.call(@expert_call)
      raise Stripe::APIConnectionError, payment.api_error if payment.respond_to?(:api_error)
      raise Stripe::StripeError, payment.error if payment.respond_to?(:error)

      @client_secret = payment[:client_secret]
      @expert_call.update!(payment_id: payment.id, payment_status: payment.status)
    end

    Transactions::Create.call(@expert_call, payment, false)
    Notifications::Experts::ExpertCallNotifier.new(@expert_call).new_call
    Notifications::Individuals::ExpertCallNotifier.new(@expert_call).new_call
  end

  def index
    @expert_calls = @individual.expert_calls_to_list
                               .most_recent
                               .page(params[:page])
                               .per(params[:per_page])
  end

  def show
    @expert_call = @individual.expert_calls.find(params[:expert_call_id])
  end

  def new_chat_room
    @expert_call = @individual.expert_calls.find(params[:expert_call_id])
    if @expert_call.chat_room.present?
      render json: @expert_call.chat_room
    else
      chat_room = TwilioServices::CreateConversation.call(@expert_call.id)
      if chat_room[:error].present?
        json_error_response(chat_room[:error], :bad_request)
      else
         render json: chat_room
      end
    end
  end

  def chat_room
    @expert_call = @individual.expert_calls.find(params[:expert_call_id])
    render json: {chat_room: @expert_call.chat_room}
  end

  private

  def expert_call_params
    params.require(:expert_call).permit(
      :expert_id, :category_id, :description, :call_type, :title, :scheduled_time_start,
      :scheduled_call_duration, :stripe_payment_method_id, guest_ids: []
    )
  end
end
