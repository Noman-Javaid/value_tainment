# frozen_string_literal: true

# related to Stripe transactions
module Stripes
  module Payments
    # handles the payment_intent confirmation related to an Interaction(q_question, exp_call)
    class ConfirmationHandler < BaseHandler
      private

      # a further action could be required and may be related with 3d secure
      def payment_required_further_action?(payment_intent)
        payment_intent.status != 'succeeded'
      end

      def payment_operation
        Stripe::PaymentIntent.confirm(@payment_id)
      end

      def transaction_charge_type
        Transaction::CHARGE_TYPE_ON_INTENT_CREATED
      end

      def status_transition
        # @TODO check if we want a new state here after the payment authorization
        # @interaction.transfer
      end
    end
  end
end
