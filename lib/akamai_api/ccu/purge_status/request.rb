require "httparty"

require "akamai_api/unauthorized"
require "akamai_api/ccu/error"
require "akamai_api/ccu/purge_status/response"
require "akamai_api/ccu/purge_status/not_found"

module AkamaiApi::CCU::PurgeStatus
  # {Request} is used to check the status of a purge request using Akamai CCU.
  #
  # @example Check using {AkamaiApi::CCU::Purge::Response#purge_id}
  #     purge_id # => "12345678-1234-5678-1234-123456789012"
  #     AkamaiApi::CCU::PurgeStatus::Request.execute(purge_id)
  # @example Check using {AkamaiApi::CCU::Purge::Response#progress_uri}
  #     progress_uri # => "/CCU/v2/purges/12345678-1234-5678-1234-123456789012"
  #     AkamaiApi::CCU::PurgeStatus::Request.execute(progress_uri)
  class Request
    include HTTParty
    format :json
    base_uri 'https://api.ccu.akamai.com'

    # Checks the status of the requested associated with the given argument
    # @param [String] purge_id_or_progress_uri a purge request ID or URI
    # @return [Response] an object detailing the response
    # @raise [AkamaiApi::CCU::PurgeStatus::NotFound] when the request cannot be found
    # @raise [AkamaiApi::CCU::Error] when there is an error in the request
    # @raise [AkamaiApi::Unauthorized] when login credentials are invalid
    def self.execute purge_id_or_progress_uri
      new.execute purge_id_or_progress_uri
    end

    # Checks the status of the requested associated with the given argument
    # @return [Response] an object detailing the response
    # @raise [AkamaiApi::CCU::PurgeStatus::NotFound] when the request cannot be found
    # @raise [AkamaiApi::CCU::Error] when there is an error in the request
    # @raise [AkamaiApi::Unauthorized] when login credentials are invalid
    def execute purge_id_or_progress_uri
      purge_id_or_progress_uri = normalize_progress_uri purge_id_or_progress_uri
      response = self.class.get purge_id_or_progress_uri, basic_auth: AkamaiApi.auth
      parse_response response
    end

    private

    def parse_response response
      raise AkamaiApi::Unauthorized if response.code == 401
      parsed = response.parsed_response
      raise AkamaiApi::CCU::Error.new parsed unless successful_response? parsed
      raise AkamaiApi::CCU::PurgeStatus::NotFound.new parsed unless parsed['submissionTime']
      AkamaiApi::CCU::PurgeStatus::Response.new(parsed)
    end

    def normalize_progress_uri progress_uri
      progress_uri = "/#{progress_uri}" unless progress_uri =~ /^\//
      if progress_uri =~ /\/ccu\/v2\/purges\//
        progress_uri
      else
        "/ccu/v2/purges#{progress_uri}"
      end
    end

    def successful_response? parsed_response
      (200...300).include? parsed_response['httpStatus']
    end
  end
end
