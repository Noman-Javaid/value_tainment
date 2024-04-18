# frozen_string_literal: true

# related to Stripe trasactions
module Stripes
  module Payments
    # handles the payment_intent cancelation related to an Interaction(q_question, exp_call)
    class CancelationHandler < BaseHandler
      private

      # a further action could be required and may be related with 3d secure
      def payment_required_further_action?(payment_intent)
        payment_intent.status != 'canceled'
      end

      def payment_operation
        Stripe::PaymentIntent.cancel(@payment_id)
      end

      def transaction_charge_type
        Transaction::CHARGE_TYPE_CANCELATION
      end

      def status_transition
        @interaction.refund
      end
    end
  end
end
