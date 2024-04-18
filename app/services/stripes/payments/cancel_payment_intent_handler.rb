# frozen_string_literal: true

# related to capture the payment from stripe
module Stripes
  module Payments
    # handles the cancellation of the payment_intent
    class CancelPaymentIntentHandler < BaseHandler
      private

      # a further action could be required and may be related with 3d secure
      def payment_required_further_action?(payment_intent)
        false
      end

      def payment_operation
        Stripe::PaymentIntent.cancel(@payment_id)
      end

      def transaction_charge_type
        Transaction::CHARGE_TYPE_CANCELATION
      end

      def status_transition
      end
    end
  end
end
