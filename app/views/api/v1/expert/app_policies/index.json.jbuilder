json.status :success
json.policies do
  json.cancellation_policy @policies.find_by(title: 'Cancellation Policy'), partial: 'api/v1/expert/app_policies/policy_details', as: :policy

  json.rescheduling_policy @policies.find_by(title: 'Rescheduling Policy'), partial: 'api/v1/expert/app_policies/policy_details', as: :policy

  json.suggest_new_time_policy @policies.find_by(title: 'Suggest New Time Policy'), partial: 'api/v1/expert/app_policies/policy_details', as: :policy
end
