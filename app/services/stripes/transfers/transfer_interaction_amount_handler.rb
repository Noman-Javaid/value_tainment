module Stripes
  module Transfers
    class TransferInteractionAmountHandler
      include Stripes::BaseService

      def initialize(interaction)
        @interaction = interaction
      end

      def self.call(...)
        new(...).call
      end

      def call
        return unless @interaction

        execute_transfer_operation
      end

      private

      def execute_transfer_operation
        retries ||= 0
        begin
          transfer_operation
        rescue Stripe::RateLimitError, Stripe::APIConnectionError => e
          retry if (retries += 1) < 3
          notify_error(e)
          api_error_response(e.message)
        rescue Stripe::AuthenticationError, Stripe::InvalidRequestError => e
          notify_error(e)
          api_error_response(e.message)
        rescue Stripe::CardError => e
          notify_error(e)
          error_response("A transfer error occurred: #{e.message}")
        rescue Stripe::StripeError => e
          notify_error(e)
          error_response("Transfer service error occurred: #{e.message}")
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

      def transfer_operation
        Stripe::Transfer.create(transfer_params)
      end

      def transfer_params
        {
          amount: amount_to_transfer_to_expert,
          currency: CURRENCY,
          destination: destination,
          metadata: metadata
        }
      end

      def amount_to_transfer_to_expert
        @amount_to_transfer_to_expert ||= (amount * @interaction.expert.payout_percentage_value).to_i
      end

      def amount
        if @interaction.instance_of?(QuickQuestion)
          @amount ||= @interaction.rate * USD_CURRENCY_FACTOR
        elsif @interaction.instance_of?(ExpertCall)
          @amount ||= (@interaction.rate + time_additions_rate) * USD_CURRENCY_FACTOR
        elsif @interaction.instance_of?(Message)
          @amount ||= @interaction.rate * USD_CURRENCY_FACTOR
        end
      end

      def time_additions_rate
        @interaction.time_additions.confirmed.sum { |h| h[:rate] }
      end

      def destination
        @interaction.expert.stripe_account_id
      end

      def metadata
        {
          expert_id: @interaction.expert.id,
          interaction_id: @interaction.id,
          interaction_type: @interaction.class.to_s
        }
      end
    end
  end
end
