json.status :success
json.data do
  json.transactions @transactions, partial: 'api/v1/expert/transactions/transaction', as: :transaction
  json.results @transactions.size
  json.has_more !@transactions.last_page?
end
