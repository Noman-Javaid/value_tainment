class Api::V1::Individual::PaymentsController < Api::V1::Individual::IndividualsController
  def public_key
    # TODO: In a near future, this will be provided by the Stripe service object.
    @public_key = Rails.application.credentials.dig(Rails.env.to_sym, :stripe, :public_key)
  end

  # returns a ephemeral_key generated for the stripe customer related to the individual
  def ephemeral_key
    @ephemeral_key = Stripes::IndividualHandler.new(@individual).create_ephemeral_key
  rescue Stripe::InvalidRequestError, Stripe::APIError => e
    Honeybadger.notify(e)
    json_error_response(error_data(e), :unprocessable_entity)
  end

  def client_secret_key
    @client_secret = Stripes::IndividualHandler.new(@individual).create_client_secret(params[:amount].to_f, params[:currency])
    render 'api/v1/individual/payments/link_payer'
  rescue Stripe::InvalidRequestError, Stripe::APIError => e
    Honeybadger.notify(e)
    json_error_response(error_data(e), :unprocessable_entity)
  end
end
