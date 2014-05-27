require "httparty"
require "akamai_api/unauthorized"
require "akamai_api/ccu/purge_status/successful_response"
require "akamai_api/ccu/purge_status/not_found_response"

module AkamaiApi::Ccu::PurgeStatus
  # This class encapsulates the behavior needed to check a purge request status using Akamai CCU.
  # Use {#execute} to check the status of a given purge request.
  #
  # @example Check using {AkamaiApi::Ccu::Purge::Response#purge_id}
  #     purge_id # => "12345678-1234-5678-1234-123456789012"
  #     AkamaiApi::Ccu::PurgeStatus::Request.execute(purge_id)
  # @example Check using {AkamaiApi::Ccu::Purge::Response#progress_uri}
  #     progress_uri # => "/ccu/v2/purges/12345678-1234-5678-1234-123456789012"
  #     AkamaiApi::Ccu::PurgeStatus::Request.execute(progress_uri)
  class Request
    include HTTParty
    format :json
    base_uri 'https://api.ccu.akamai.com'

    # Checks the status of the requested associated with the given argument
    # @return [NotFoundResponse] when no request can be found with the given argument
    # @return [SuccessfulResponse] when a request has been found
    # @raise [AkamaiApi::Unauthorized] when login credentials are invalid
    def self.execute purge_id_or_progress_uri
      new.execute purge_id_or_progress_uri
    end

    # Checks the status of the requested associated with the given argument
    # @return [NotFoundResponse] when no request can be found with the given argument
    # @return [SuccessfulResponse] when a request has been found
    # @raise [AkamaiApi::Unauthorized] when login credentials are invalid
    def execute purge_id_or_progress_uri
      purge_id_or_progress_uri = normalize_progress_uri purge_id_or_progress_uri
      response = self.class.get purge_id_or_progress_uri, basic_auth: AkamaiApi.auth
      parse_response response
    end

    private

    def parse_response response
      raise AkamaiApi::Unauthorized if response.code == 401
      build_response response.parsed_response
    end

    def normalize_progress_uri progress_uri
      progress_uri = "/#{progress_uri}" unless progress_uri =~ /^\//
      if progress_uri =~ /\/ccu\/v2\/purges\//
        progress_uri
      else
        "/ccu/v2/purges#{progress_uri}"
      end
    end

    def build_response parsed_response
      response_class = parsed_response['submittedBy'] ? SuccessfulResponse : NotFoundResponse
      response_class.new parsed_response
    end
  end
end
