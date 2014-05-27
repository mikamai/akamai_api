require "akamai_api/eccu/base_edit_request"
require "akamai_api/eccu/find_response"

module AkamaiApi::Eccu
  # The {FindRequest} class is used to get the details of an ECCU request.
  #
  # @example
  #   begin
  #     res = AkamaiApi::Eccu::FindRequest.execute 12345, false
  #     puts "Request found, in status #{res.status[:message]}"
  #   rescue AkamaiApi::Unauthorized
  #     puts "Invalid credentials"
  #   rescue AkamaiApi::NotFound
  #     puts "No request found with the given code"
  #   end
  class FindRequest < BaseEditRequest
    # Returns the details of an ECCU request
    # @param [Fixnum] code request code
    # @param [true,false] retrieve_content set to true if you want to retrieve request content too
    # @return [FindResponse]
    def self.execute code, retrieve_content = false
      new(code).execute(retrieve_content)
    end

    # Returns the details of an ECCU request
    # @param [true,false] retrieve_content set to true if you want to retrieve request content too
    # @return [FindResponse]
    def execute retrieve_content = false
      with_soap_error_handling do
        response = client_call :get_info, message: request_body(retrieve_content).to_s
        FindResponse.new response[:eccu_info]
      end
    end

    protected

    def request_body retrieve_content
      super do |block|
        block.boolean :retrieveContents, retrieve_content == true
      end
    end
  end
end
