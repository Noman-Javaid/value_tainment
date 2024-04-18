json.extract! transaction, :id, :created_at
json.paid transaction.charge_type == Transaction::CHARGE_TYPE_CONFIRMATION
json.expert transaction.expert, partial: 'api/v1/expert/transactions/expert', as: :expert
json.individual transaction.individual, partial: 'api/v1/expert/transactions/individual',
                                        as: :individual
json.expert_interaction transaction,
                        partial: 'api/v1/expert/transactions/expert_interaction',
                        as: :transaction
