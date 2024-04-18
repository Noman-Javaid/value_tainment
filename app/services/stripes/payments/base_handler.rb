module Stripes
  module Payments
    class BaseHandler
      def initialize(interaction)
        @interaction = interaction
        @payment_id = interaction&.payment_id
        check_payment_id
      end

      def self.call(...)
        new(...).call
      end

      def call
        return unless @interaction

        payment_intent = execute_payment_operation
        update_interaction!(payment_intent) if payment_intent
      end

      private

      def execute_payment_operation
        payment_operation
      rescue Stripe::RateLimitError, Stripe::APIConnectionError => e
        # Too many requests made to the API too quickly - a retry could be possible a fix
        Honeybadger.notify(e)
        nil
      rescue Stripe::CardError, Stripe::InvalidRequestError, Stripe::AuthenticationError,
             Stripe::StripeError => e
        # Invalid parameters were supplied to Stripe's API - manual revision required
        Honeybadger.notify(e, context: error_context)
        error_response(e.message)
      end

      def update_interaction!(payment_intent)
        if payment_failed?(payment_intent) && !instance_of?(Stripes::Payments::CapturePaymentHandler) # rubocop:disable Style/GuardClause
          return update_payment_status!(payment_intent.error)
        elsif payment_required_further_action?(payment_intent)
          return update_payment_status!(payment_intent.status)
        end

        status_transition
        update_payment_status!(payment_intent.status)
        save_transaction!(payment_intent) unless instance_of?(Stripes::Payments::CapturePaymentHandler)
      end

      def transaction_charge_type; end

      def error_context
        @error_context ||= {
          related_to: "Error in payment_id #{@interaction.payment_id} with "\
                            "#{@interaction.class} #{@interaction.id}"
        }
      end

      def error_response(error_message)
        OpenStruct.new(error: error_message)
      end

      # payment_failed? and payment_required_further_action? an event notification about
      # this state, this is uncommon but could happen
      def payment_failed?(payment_intent)
        payment_intent.respond_to?(:error)
      end

      # a further action could be required and may be related with 3d secure
      def payment_required_further_action?(payment_intent); end

      def update_payment_status!(status)
        @interaction.update!(payment_status: status)
      end

      def save_transaction!(payment_intent)
        Transaction.create!(
          expert: @interaction.expert, expert_interaction: @interaction.expert_interaction,
          individual: @interaction.individual, charge_type: transaction_charge_type,
          stripe_transaction_id: payment_intent.id, amount: payment_intent.amount
        )
      end

      def check_payment_id
        raise ArgumentError, 'Missing payment_id value' if @interaction &&
                                                           @payment_id.blank?
      end

      def payment_operation; end

      def status_transition; end
    end
  end
end
