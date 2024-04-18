# frozen_string_literal: true

# related to capture the payment from stripe
module Stripes
  module Payments
    # handles the payment_intent capture related to a stripe_payment_id
    class CapturePaymentHandler < BaseHandler
      private

      # a further action could be required and may be related with 3d secure
      def payment_required_further_action?(payment_intent)
        payment_intent.status != 'succeeded'
      end

      def payment_operation
        Stripe::PaymentIntent.capture(@payment_id)
      end

      def transaction_charge_type
        Transaction::CHARGE_TYPE_CONFIRMATION
      end

      def status_transition
        # transfer only in case of quick question.
        # video calls will be transferred after the call is finish
        @interaction.transfer if @interaction.instance_of?(QuickQuestions)
      end
    end
  end
end
