require "akamai_api/eccu/base_edit_request"

module AkamaiApi::Eccu
  class DestroyRequest < BaseEditRequest
    def execute
      with_soap_error_handling do
        client_call(:delete, message: request_body.to_s)[:success]
      end
    end
  end
end
