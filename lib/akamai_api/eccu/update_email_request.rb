require "savon"

require "akamai_api/eccu/base_request"
require "akamai_api/eccu/soap_body"

module AkamaiApi::Eccu
  class UpdateEmailRequest < BaseRequest
    def execute email
      with_soap_error_handling do
        response = client_call :set_status_change_email, message: request_body(email).to_s
        response.body[:set_status_change_email_response][:success]
      end
    end

    def request_body email
      SoapBody.new.tap do |body|
        body.integer :fileId, code
        body.string  :statusChangeEmail, email
      end
    end
  end
end
