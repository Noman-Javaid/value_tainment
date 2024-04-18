module Devise
  module Failures
    class CustomFailureApp < Devise::FailureApp
      def respond
        # TODO: Possibly, this condition has the ability to mess with an eventual non-API JSON response.
        # TODO: It needs further verification.
        if request.format == :json
          json_error_response(custom_message)
        else
          super
        end
      end

      def json_error_response(message)
        self.status = 401
        self.content_type = 'application/json'
        self.response_body = {
          status: :error,
          message: message
        }.to_json
      end

      def custom_message
        i18n_message(request.controller_class.respond_to?(:custom_message) ? request.controller_class.custom_message(self) : nil)
      end

      def fetch_message(message)
        i18n_message(message)
      end

      def current_message
        warden_message
      end
    end
  end
end
