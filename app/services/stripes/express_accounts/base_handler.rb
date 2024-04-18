module Stripes
  module ExpressAccounts
    class BaseHandler
      def initialize(expert)
        @expert = expert
        @account_id = expert&.stripe_account_id
        check_account_id
      end

      def self.call(...)
        new(...).call
      end

      def call
        return unless @expert

        execute_account_operation
      end

      private

      def execute_account_operation
        account_operation
      rescue Stripe::RateLimitError, Stripe::APIConnectionError => e
        # Too many requests made to the API too quickly - a retry could be possible a fix
        Honeybadger.notify(e)
        nil
      rescue Stripe::InvalidRequestError, Stripe::AuthenticationError,
             Stripe::StripeError => e
        # Invalid parameters were supplied to Stripe's API - manual revision required
        Honeybadger.notify(e, context: error_context)
        error_response(e.message)
      end

      def error_context
        @error_context ||= {
          related_to: "Error in getting account info with Expert #{@expert.id}"
        }
      end

      def error_response(error_message)
        OpenStruct.new(error: error_message)
      end

      def check_account_id
        raise ArgumentError, 'Missing account_id value' if @expert &&
                                                           @account_id.blank?
      end

      def account_operation; end
    end
  end
end
