require "akamai_api/ccu/response"

module AkamaiApi::Ccu::PurgeStatus
  # @abstract
  # This class is intended as a generic superclass for all the specific responses
  # that can be received when doing a request through the Purge Status Akamai CCU interface
  class Response < ::AkamaiApi::Ccu::Response

    # URI to use to ask the status. It can be used to ask the request status to AkamaiApi
    # @return [String] URI to use to ask the status
    def uri
      raw['progressUri']
    end

    alias_method :progress_uri, :uri

    # Request ID assigned from Akamai. It can be used to ask the request status to AkamaiApi
    # @return [String] request ID assigned from Akamai
    def purge_id
      raw['purgeId']
    end

    # Status of the purge request
    # @return [String] Status of the purge request. It can be one of the following values:
    #   - In-Progress (request is being completed)
    #   - Done (request completed)
    #   - Unknown
    def status
      raw['purgeStatus']
    end

    alias_method :purge_status, :status

    # Suggested time to wait (in seconds) before asking the status to Akamai
    # @return [Fixnum] suggested time to wait (in seconds) before asking the status to Akamai
    def time_to_wait
      raw['pingAfterSeconds']
    end

    alias_method :ping_after_seconds, :time_to_wait
  end
end
