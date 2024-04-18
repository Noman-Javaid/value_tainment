# frozen_string_literal: true

# related to Stripe transactions
module Stripes
  module Payments
    # handles the payment creation related to an Interaction
    class InteractionPaymentHandler < BaseCreatorHandler
      private

      def payment_method
        @payment_method ||= @interaction.stripe_payment_method_id
      end

      def customer
        @customer ||= @interaction.individual.stripe_customer_id
      end

      def expert_account
        @expert_account ||= @interaction.expert.stripe_account_id
      end

      def expert_id
        @expert_id ||= @interaction.expert_id
      end

      def metadata
        {
          amount_to_transfer_to_expert: amount_to_transfer_to_expert,
          amount_to_transfer_to_expert_in_dollars: amount_to_transfer_to_expert_in_dollars,
          expert_id: expert_id,
          expert_connected_account_id: expert_account,
          interaction_id: @interaction.id,
          interaction_type: @interaction.class.to_s
        }
      end
    end
  end
end
