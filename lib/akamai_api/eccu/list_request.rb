require "akamai_api/eccu/soap_body"
require "akamai_api/eccu/base_request"

module AkamaiApi::Eccu
  class ListRequest < BaseRequest
    def initialize
      super nil
    end

    def execute
      with_soap_error_handling do
        Array.wrap client_call(:get_ids).body[:get_ids_response][:file_ids][:file_ids]
      end
    end
  end
end
