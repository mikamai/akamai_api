module AkamaiApi::Ccu::PurgeStatus
  class Request
    include HTTParty
    format :json
    base_uri 'https://api.ccu.akamai.com'

    def execute progress_uri
      response = self.class.get normalize_progress_uri(progress_uri), basic_auth: auth
      parse_response response
    end

    def auth
      AkamaiApi::Ccu.auth
    end

    private

    def parse_response response
      raise AkamaiApi::Unauthorized if response.code == 401
      AkamaiApi::Ccu::PurgeStatus.build_response response.parsed_response
    end

    def normalize_progress_uri progress_uri
      progress_uri = "/#{progress_uri}" unless progress_uri =~ /^\//
      if progress_uri =~ /\/ccu\/v2\/purges\//
        progress_uri
      else
        "/ccu/v2/purges#{progress_uri}"
      end
    end
  end
end
