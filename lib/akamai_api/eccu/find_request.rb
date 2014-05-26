require "akamai_api/eccu/base_edit_request"
require "akamai_api/eccu/find_response"

module AkamaiApi::Eccu
  class FindRequest < BaseEditRequest
    def execute retrieve_content
      with_soap_error_handling do
        response = client_call :get_info, message: request_body(retrieve_content).to_s
        FindResponse.new response[:eccu_info]
      end
    end

    def request_body retrieve_content
      super do |block|
        block.boolean :retrieveContents, retrieve_content == true
      end
    end
  end
end
