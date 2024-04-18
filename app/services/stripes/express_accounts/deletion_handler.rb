# frozen_string_literal: true

# related to Stripe trasactions
module Stripes
  module ExpressAccounts
    # handles the deletion of the connected express account
    class DeletionHandler < BaseHandler
      def call
        return unless @expert

        account_response = execute_account_operation
        update_expert!(account_response) if account_response
      end

      private

      def account_operation
        Stripe::Account.delete(@account_id)
      end

      def update_expert!(account_response)
        return if account_response.respond_to?(:error)

        @expert.update!(ready_for_deletion: account_response.deleted)
      end
    end
  end
end
