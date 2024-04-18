# frozen_string_literal: true

# related to Stripe trasactions
module Stripes
  # handles the transactions related to an Individual
  class IndividualHandler
    attr_reader :individual

    def initialize(individual)
      @individual = individual
    end

    # creates a stripe customer and assigns the stripe_customer_id to the individual
    def create_customer
      return if individual.stripe_customer_id.present?

      customer = Stripe::Customer.create(
        email: individual.email,
        name: individual.name,
        metadata: {
          individual_id: individual.id
        }
      )
      individual.update(stripe_customer_id: customer['id'])
    end

    # generates a ephemeral_key for the mobile app to handle strip customer data
    def create_ephemeral_key
      Stripe::EphemeralKey.create(
        { customer: individual.stripe_customer_id }, stripe_version: Stripe.api_version
      )
    end

    def create_client_secret(amount, currency = 'usd')
      payment_intent = Stripe::PaymentIntent.create({
                                     amount: (amount * Stripes::BaseService::USD_CURRENCY_FACTOR).to_i,
                                     currency: currency,
                                     automatic_payment_methods: {enabled: true}
                                   })
      payment_intent[:client_secret]
    end

    def get_credit_card_list(limit = nil)
      limit ||= 10
      credit_card_list = Stripe::PaymentMethod.list(
        { customer: @individual.stripe_customer_id, type: 'card', limit: limit }
      )
      {
        credit_cards: format_credit_card_list_data(credit_card_list.data),
        has_more: credit_card_list.has_more
      }
    end

    def delete_customer
      return if individual.stripe_customer_id.blank?

      Stripe::Customer.delete(individual.stripe_customer_id)
    end

    private

    def format_credit_card_list_data(data)
      data.map do |credit_card|
        {
          id: credit_card.id,
          brand: credit_card.card.brand,
          last_digits: credit_card.card.last4
        }
      end
    end
  end
end
