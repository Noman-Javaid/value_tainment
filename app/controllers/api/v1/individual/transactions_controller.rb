class Api::V1::Individual::TransactionsController < Api::V1::Individual::IndividualsController
  def index
    @transactions = @individual.transactions
                               .includes(:time_addition, { expert_interaction: :interaction })
                               .most_recent
                               .page(params[:page])
                               .per(params[:per_page])
    render '/api/v1/expert/transactions/index'
  end
end
