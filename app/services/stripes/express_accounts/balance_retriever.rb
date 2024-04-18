# frozen_string_literal: true

# related to Stripe trasactions
module Stripes
  module ExpressAccounts
    # handles the deletion of the connected express account
    class BalanceRetriever < BaseHandler
      private

      def account_operation
        Stripe::Balance.retrieve({ stripe_account: @account_id })
      end
    end
  end
end
