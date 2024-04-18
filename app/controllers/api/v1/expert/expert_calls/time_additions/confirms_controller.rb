class Api::V1::Expert::ExpertCalls::TimeAdditions::ConfirmsController <
      Api::V1::Expert::ExpertCallsController
  before_action :set_expert_call, :set_time_addition, only: %i[update]

  def update
    case time_addition_params[:status]
    when 'confirmed'
      payment = Stripes::Payments::TimeAdditionPaymentHandler.call(@time_addition)
      raise Stripe::APIConnectionError, payment.api_error if payment.respond_to?(:api_error)
      raise Stripe::StripeError, payment.error if payment.respond_to?(:error)
      @time_addition.update!(payment_id: payment.id, payment_status: payment.status)
      @time_addition.confirm
      Transactions::Create.call(@time_addition, payment, false)
    when 'declined'
      @time_addition.decline!
    else
      return json_error_response('Invalid request data', :bad_request)
    end
    Notifications::Individuals::ExpertCalls::TimeAdditionNotifier.new(@time_addition)
                                                                 .execute
    render 'api/v1/individual/expert_calls/time_additions/create'
  end

  private

  def set_expert_call
    @expert_call = @expert.expert_calls.find(params[:expert_call_id])
  end

  def set_time_addition
    @time_addition = @expert_call.time_additions.find(params[:time_addition_id])
  end

  def time_addition_params
    params.require(:time_addition).permit(:status)
  end
end
