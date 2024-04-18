class Api::V1::Expert::PaymentsController < Api::V1::Expert::ExpertsController
  def connect_account
    @account_link = Stripes::ExpertHandler.new(@expert).create_connect_account
  end
end
