require "akamai_api/eccu/base_edit_request"

module AkamaiApi::ECCU
  # The {DestroyRequest} class is used to delete an ECCU request.
  #
  # @example
  #   AkamaiApi::ECCU::DestroyRequest.execute(12345)
  class DestroyRequest < BaseEditRequest
    # Deletes an ECCU request
    # @param [Fixnum] code request code
    # @return [true] when the request has been deleted
    # @return [false] when the request cannot be deleted
    # @raise [AkamaiApi::Unauthorized] when login credentials are invalid
    # @raise [AkamaiApi::ECCU::NotFound] when no request can be found with the given code
    def self.execute code
      new(code).execute
    end

    # Deletes an ECCU request
    # @return [true] when the request has been deleted
    # @return [false] when the request cannot be deleted
    # @raise [AkamaiApi::Unauthorized] when login credentials are invalid
    # @raise [AkamaiApi::ECCU::NotFound] when no request can be found with the given code
    def execute
      with_soap_error_handling do
        client_call(:delete, message: request_body.to_s)[:success]
      end
    end
  end
end
