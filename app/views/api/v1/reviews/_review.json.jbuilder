json.extract! expert_interaction, :was_helpful, :rating, :feedback, :created_at, :updated_at, :reviewed_at
json.individual expert_interaction.interaction.individual, partial: 'api/v1/individual/individual', as: :individual
