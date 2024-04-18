class Api::V1::Expert::ExpertsController < Api::V1::ApiController
  around_action :set_expert

  def set_expert
    return json_error_response('Unauthorized', :unauthorized) unless current_user.as_expert?

    @expert = current_user.expert
    yield
  end
end
