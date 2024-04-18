class Api::V1::Expert::TransactionsController < Api::V1::Expert::ExpertsController
  def index
    @transactions = @expert.transactions
                           .includes(:time_addition, { expert_interaction: :interaction })
                           .most_recent
                           .page(params[:page])
                           .per(params[:per_page])
  end
end
