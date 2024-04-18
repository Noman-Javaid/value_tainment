json.status :error
json.message @message
json.code @code if @code
json.two_factor_code_sent_to @two_factor_code_sent_to if @two_factor_code_sent_to
