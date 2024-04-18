json.status :success
json.data do
  json.customer_id @individual.stripe_customer_id
  json.credit_cards @credit_card_list[:credit_cards], partial: 'api/v1/individual/payments/credit_cards/credit_card', as: :credit_card
  json.has_more @credit_card_list[:has_more]
end
