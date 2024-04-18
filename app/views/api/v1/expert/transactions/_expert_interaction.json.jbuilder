json.extract! transaction.expert_interaction, :interaction_id, :interaction_type
if transaction.expert_interaction.interaction_type == 'ExpertCall'
  json.call_type transaction.expert_interaction.interaction.call_type
  json.extra_user transaction.expert_interaction.interaction.extra_users?
  json.extra_user_rate transaction.expert_interaction.interaction.extra_user_rate
  json.is_time_addition !transaction.time_addition.nil?
end
if transaction.time_addition
  json.rate transaction.time_addition.rate
else
  json.rate transaction.expert_interaction.interaction.rate
end
