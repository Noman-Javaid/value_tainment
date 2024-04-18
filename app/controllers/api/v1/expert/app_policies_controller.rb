class Api::V1::Expert::AppPoliciesController < Api::V1::Expert::ExpertsController

  def index
    @policies = AppPolicy.expert_policies.active
  end
end
