# frozen_string_literal: true

# Related to APi requests
module Api
  # V1
  module V1
    # related to expert endpoints
    module Expert
      # related to payment actions
      module Payments
        # Hanldes the bank account setup
        class BankAccountsController < Api::V1::Expert::ExpertsController
          # setups a new bank account
          def create
            Stripes::ExpertHandler.new(@expert).create_bank_account!(bank_account_params)
            render partial: '/api/v1/expert/expert', locals: { expert: @expert }
          end

          private

          def bank_account_params
            params.require(:bank_account).permit(:account_number, :routing_number)
          end
        end
      end
    end
  end
end
