module Api::V1::Concerns::ApiResponses
  def json_fail_response(data = nil, status = :bad_request)
    @data = data
    render 'api/v1/errors/fail', status: status
  end

  def json_error_response(message = nil, status = :bad_request, two_factor = {})
    @message = message
    @code = two_factor[:error_code]
    @two_factor_code_sent_to = two_factor[:code_sent_to]
    render 'api/v1/errors/error', status: status
  end
end
