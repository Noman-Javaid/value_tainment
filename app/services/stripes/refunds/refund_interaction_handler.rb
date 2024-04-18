module Stripes
  module Refunds
    class RefundInteractionHandler
      def initialize(interaction, amount = 0)
        @interaction = interaction
        @amount = amount
      end

      def self.call(...)
        new(...).call
      end

      def call
        return unless @interaction

        execute_refund_operation
      end

      private

      def execute_refund_operation
        retries ||= 0
        begin
          refund_operation
        rescue Stripe::RateLimitError, Stripe::APIConnectionError => e
          retry if (retries += 1) < 3
          notify_error(e)
          api_error_response(e.message)
        rescue Stripe::AuthenticationError, Stripe::InvalidRequestError => e
          notify_error(e)
          api_error_response(e.message)
        rescue Stripe::CardError => e
          notify_error(e)
          error_response("A refund error ocurred: #{e.message}")
        rescue Stripe::StripeError => e
          notify_error(e)
          error_response("Refund service error ocurred: #{e.message}")
        end
      end

      def notify_error(error)
        Honeybadger.notify(error, context: error_context(self.class))
      end

      def error_context(klass = nil)
        @error_context ||= {
          related_to: klass,
          interaction_type: @interaction.class,
          interaction_id: @interaction.id
        }
      end

      def error_response(error_message)
        OpenStruct.new(error: error_message)
      end

      def api_error_response(error_message)
        OpenStruct.new(api_error: error_message, context: error_context(self.class))
      end

      def refund_operation
        Stripe::Refund.create(
          {
            payment_intent: @interaction.payment_id,
            metadata: metadata,
            amount: @amount
          }
        )
      end

      def metadata
        {
          expert_id: @interaction.instance_of?(TimeAddition) ? @interaction.expert_call.expert.id : @interaction.expert.id,
          interaction_id: @interaction.id,
          interaction_type: @interaction.class.to_s
        }
      end
    end
  end
end
