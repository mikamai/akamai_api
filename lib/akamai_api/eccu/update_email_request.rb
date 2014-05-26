require "akamai_api/eccu/base_edit_request"
require "akamai_api/eccu/soap_body"

module AkamaiApi::Eccu
  class UpdateEmailRequest < BaseEditRequest
    def execute email
      with_soap_error_handling do
        client_call(:set_status_change_email, message: request_body(email).to_s)[:success]
      end
    end

    def request_body email
      super do |block|
        block.string  :statusChangeEmail, email
      end
    end
  end
end
