require "httparty"
require "akamai_api/unauthorized"
require "akamai_api/ccu/purge_status/successful_response"
require "akamai_api/ccu/purge_status/not_found_response"

module AkamaiApi::Ccu::PurgeStatus
  class Request
    include HTTParty
    format :json
    base_uri 'https://api.ccu.akamai.com'

    def execute progress_uri
      response = self.class.get normalize_progress_uri(progress_uri), basic_auth: AkamaiApi.auth
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
