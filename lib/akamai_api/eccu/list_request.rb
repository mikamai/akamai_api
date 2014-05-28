require "akamai_api/eccu/soap_body"
require "akamai_api/eccu/base_request"

module AkamaiApi::ECCU
  # Use the {ListRequest} class to get the list of the last submitted ECCU requests
  class ListRequest < BaseRequest
    # Returns the list of the last submitted ECCU requests
    # @return [Array<Fixnum>] list of request codes
    def self.execute
      new.execute
    end

    # Returns the list of the last submitted ECCU requests
    # @return [Array<Fixnum>] list of request codes
    def execute
      with_soap_error_handling do
        Array.wrap client_call(:get_ids)[:file_ids][:file_ids]
      end
    end
  end
end
