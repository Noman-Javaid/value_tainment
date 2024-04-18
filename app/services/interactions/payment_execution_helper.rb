module Interactions
  class PaymentExecutionHelper
    VALID_STATUSES_TO_CONFIRM = %w[answered finished denied_complaint filed_complaint requires_capture].freeze
    VALID_STATUSES_TO_CANCEL = %w[approved_complaint].freeze
    VALID_PAYMENT_STATUSES = %w[requires_confirmation requires_capture].freeze

    # TODO- Update account deletion flow, transfer(with payment_status=succeded) instead of payment
    def initialize(interactions, as_individual)
      @interactions = interactions
      @as_individual = as_individual
    end

    def self.call(...)
      new(...).call
    end

    def call
      return unless @interactions&.any?

      @interactions.each do |interaction|
        if valid_to_confirm_payment?(interaction)
          confirmation = Stripes::Payments::ConfirmationHandler.call(interaction)
          follow_up_tracker(interaction, confirmation)
        elsif valid_to_cancel_payment?(interaction)
          cancelation = Stripes::Payments::CancelationHandler.call(interaction)
          follow_up_tracker(interaction, cancelation)
        end
      end
    end

    private

    def valid_to_execute_payment?(interaction, valid_statuses)
      if interaction.instance_of?(QuickQuestion)
        return valid_statuses.include?(interaction.status) &&
               valid_payment_status?(interaction)
      end

      valid_statuses.include?(interaction.call_status) &&
        valid_payment_status?(interaction)
    end

    def valid_to_confirm_payment?(interaction)
      valid_to_execute_payment?(interaction, VALID_STATUSES_TO_CONFIRM)
    end

    def valid_to_cancel_payment?(interaction)
      valid_to_execute_payment?(interaction, VALID_STATUSES_TO_CANCEL)
    end

    def valid_payment_status?(interaction)
      VALID_PAYMENT_STATUSES.include?(interaction.payment_status)
    end

    def follow_up_tracker(interaction, event)
      return if event.respond_to?(:status)

      stripe_error = if event.respond_to?(:error)
                       event.error
                     elsif event.nil?
                       'Api call'
                     else
                       'No error'
                     end

      note = "**In class #{self.class} with #{interaction.class} id: #{interaction.id} "\
             "as individual? -> #{@as_individual}, Stripe error: #{stripe_error}"
      user = @as_individual ? interaction.individual.user : interaction.expert.user
      AccountDeletionFollowUps::TrackerHelper.call(user, note)
    end
  end
end
