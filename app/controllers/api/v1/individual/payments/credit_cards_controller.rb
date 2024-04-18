class Api::V1::Individual::Payments::CreditCardsController < Api::V1::Individual::PaymentsController
  def index
    return missing_stripe_id_in_user(@individual.class.to_s) unless @individual.stripe_customer_id

    @credit_card_list = Stripes::IndividualHandler.new(@individual).get_credit_card_list(
      params[:limit]&.to_i
    )
  rescue Stripe::InvalidRequestError, Stripe::APIError => e
    Honeybadger.notify(e)
    json_fail_response(error_data(e), :unprocessable_entity)
  end

  private

  def missing_stripe_id_in_user(user_type)
    json_fail_response(
      "#{user_type} does not have stripe customer_id",
      :service_unavailable
    )
  end
end
