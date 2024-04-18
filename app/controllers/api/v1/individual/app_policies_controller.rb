class Api::V1::Individual::AppPoliciesController < Api::V1::Individual::IndividualsController
  def index
    @policies = AppPolicy.individual_policies.active
  end
end
