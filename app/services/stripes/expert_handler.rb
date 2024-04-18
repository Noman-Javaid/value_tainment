# frozen_string_literal: true

# related to Stripe trasactions
module Stripes
  # handles the transactions related to an Expert
  class ExpertHandler
    # https://stripe.com/docs/connect/setting-mcc
    # "Consulting, Public Relations"
    CONSULTING_SERVICES_MCC = '7392'
    BUSINESS_TYPE = 'individual'
    attr_reader :expert

    def initialize(expert)
      @expert = expert
    end

    # creates a stripe account and assigns the stripe_account_id to the expert
    # Use 'express' instead of 'standard' to provide a simpler onboarding process
    def create_connect_account
      if expert.stripe_account_id.blank?
        account = Stripe::Account.create(stripe_connected_account_params)
        expert.update!(stripe_account_id: account['id'], stripe_account_set: true)
      end
      link = Stripe::AccountLink.create(
        account: expert.stripe_account_id,
        # Bad: Expired or reused link
        # Probably it can be a mobile URI (needs further checking)
        refresh_url: ENV['STRIPE_REFRESH_URL'], # rubocop:todo Rails/EnvironmentVariableAccess
        # May be good: Maybe the user has completed the registration (need API checking)
        return_url: ENV['STRIPE_RETURN_URL'], # rubocop:todo Rails/EnvironmentVariableAccess
        type: 'account_onboarding'
      )
      link.url
    end

    # TODO: remove/update if needed
    def create_bank_account!(params)
      stripe_bank_account = Stripe::Account.create_external_account(
        expert.stripe_account_id,
        external_account: bank_account_params(params),
        default_for_currency: true
      )

      expert.update!(
        stripe_bank_account_id: stripe_bank_account.id,
        bank_account_last4: stripe_bank_account.last4
      )
    end

    # Use with payment intent flow
    def confirm_payment(payment_id)
      Stripe::PaymentIntent.confirm(payment_id)
    end

    def cancel_payment(payment_id)
      Stripe::PaymentIntent.cancel(payment_id)
    end

    private

    def stripe_connected_account_params
      # country should be an ISO 3166-1 alpha-2 country code
      {
        type: 'express',
        country: expert.user.country,
        email: expert.user.email,
        business_type: BUSINESS_TYPE,
        capabilities: {
          card_payments: { requested: true }, transfers: { requested: true }
        },
        tos_acceptance: { service_agreement: 'full' },
        metadata: {
          expert_id: expert.id
        },
        individual: {
          dob: {
            day: expert.user.date_of_birth.day,
            month: expert.user.date_of_birth.month,
            year: expert.user.date_of_birth.year
          },
          email: expert.user.email,
          first_name: expert.user.first_name,
          last_name: expert.user.last_name,
          address: {
            city: expert.user.city,
            country: expert.user.country,
            postal_code: expert.user.zip_code
          }
        },
        business_profile: {
          mcc: CONSULTING_SERVICES_MCC,
          url: expert.website_url
        }
      }
    end

    def bank_account_params(params)
      {
        object: 'bank_account',
        country: 'US',
        currency: 'usd',
        account_number: params[:account_number],
        routing_number: params[:routing_number]
      }
    end

    def delete_stripe_external_account!
      Stripe::Account.delete_external_account(
        expert.stripe_account_id,
        stripe_bank_account_id_was
      )
    rescue Stripe::StripeError => e
      errors.add(:base, e.message)
      throw(:abort)
    end
  end
end
