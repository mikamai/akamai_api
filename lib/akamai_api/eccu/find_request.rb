require "akamai_api/eccu/soap_body"
require "akamai_api/eccu/base_request"
require "akamai_api/eccu/find_response"

module AkamaiApi::Eccu
  class FindRequest < BaseRequest
    def execute retrieve_content
      with_soap_error_handling do
        response = client_call :get_info, message: request_body(retrieve_content).to_s
        FindResponse.new response[:eccu_info]
      end
    end

    def request_body retrieve_content
      SoapBody.new.tap do |body|
        body.integer :fileId, code
        body.boolean :retrieveContents, retrieve_content == true
      end
    end
  end
end
