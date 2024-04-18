module Stripes
  module Payments
    class BaseCreatorHandler
      include Stripes::BaseService

      DEFAULT_PAYMENT_METHOD_TYPE = ['card'].freeze
      ERROR_ON_REQUIRES_ACTION = true
      CONFIRM = true
      def initialize(interaction)
        @interaction = interaction
      end

      def self.call(...)
        new(...).call
      end

      def call
        return unless @interaction

        execute_payment_operation
      end

      private

      def execute_payment_operation
        retries ||= 0
        begin
          payment_operation
        rescue Stripe::RateLimitError, Stripe::APIConnectionError => e
          retry if (retries += 1) < 3
          notify_error(e)
          api_error_response(e.message)
        rescue Stripe::AuthenticationError, Stripe::InvalidRequestError => e
          notify_error(e)
          api_error_response(e.message)
        rescue Stripe::CardError => e
          notify_error(e)
          error_response("A payment error occurred: #{e.message}")
        rescue Stripe::StripeError => e
          notify_error(e)
          error_response("Payment service error occurred: #{e.message}")
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
        OpenStruct.new(api_error: error_message)
      end

      def payment_operation
        Stripe::PaymentIntent.create(payment_intent_params)
      end

      def amount
        @amount ||= @interaction.rate * USD_CURRENCY_FACTOR
      end

      def amount_to_transfer_to_expert
        @amount_to_transfer_to_expert ||= (amount * @interaction.expert.payout_percentage_value).to_i
      end

      def amount_to_transfer_to_expert_in_dollars
        @amount_to_transfer_to_expert_in_dollars ||= (amount_to_transfer_to_expert / USD_CURRENCY_FACTOR).to_i
      end

      def payment_intent_params
        {
          payment_method: payment_method,
          payment_method_types: DEFAULT_PAYMENT_METHOD_TYPE,
          amount: amount,
          currency: CURRENCY,
          customer: customer,
          error_on_requires_action: ERROR_ON_REQUIRES_ACTION,
          confirm: CONFIRM,
          metadata: metadata,
          payment_method_options: {
            card: {
              capture_method: CAPTURE_METHOD
            }
          }
        }
      end

      def payment_method; end

      def customer; end

      def expert_account; end

      def expert_id; end

      def metadata; end
    end
  end
end
