class Api::V1::Individual::IndividualsController < Api::V1::ApiController
  before_action :set_individual

  def set_individual
    return json_error_response('The user signed in is not an individual', :unauthorized) unless current_user.as_individual?

    @individual = current_user.individual
  end
end
