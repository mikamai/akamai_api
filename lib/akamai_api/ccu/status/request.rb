require "httparty"
require "akamai_api/unauthorized"
require "akamai_api/ccu/status/response"

module AkamaiApi::CCU::Status
  # {Request} can be used to check the status of the Akamai CCU queue
  class Request
    include HTTParty
    format :json
    base_uri 'https://api.ccu.akamai.com/ccu/v2/queues/default'

    # Checks the status of the Akamai CCU queue
    # @return [Response] a response object describing the status of the Akamai CCU queue
    # @raise [AkamaiApi::CCU::Error] when there is an error in the request
    # @raise [AkamaiApi::Unauthorized] when login credentials are invalid
    def self.execute
      new.execute
    end

    # Checks the status of the Akamai CCU queue
    # @return [Response] a response object describing the status of the Akamai CCU queue
    # @raise [AkamaiApi::CCU::Error] when there is an error in the request
    # @raise [AkamaiApi::Unauthorized] when login credentials are invalid
    def execute
      response = self.class.get('/', basic_auth: AkamaiApi.auth)
      parse_response response
    end

    private

    def parse_response response
      raise AkamaiApi::Unauthorized if response.code == 401
      AkamaiApi::CCU::Status::Response.new response.parsed_response
    end
  end
end
