require "akamai_api/ccu/response"

module AkamaiApi::Ccu::Purge
  # This class represents the response received after a purge request made
  # through the Akamai CCU interface using {Request}
  class Response < ::AkamaiApi::Ccu::Response
    # URL detailing the error.
    # @return [String] URL detailing the error
    # @return [nil] when the response is not representing an error
    def described_by
      raw['describedBy']
    end

    # Error specific title
    # @return [String] error specific title
    # @return [nil] when the response is not representing an error
    def title
      raw['title']
    end

    # Suggested time to wait (in seconds) before asking the status to Akamai
    # @return [Fixnum] suggested time to wait (in seconds) before asking the status to Akamai
    def time_to_wait
      raw['pingAfterSeconds']
    end

    alias_method :ping_after_seconds, :time_to_wait

    # Request ID assigned from Akamai. It can be used to ask the request status to AkamaiApi
    # @return [String] request ID assigned from Akamai
    # @return [nil] when the response represents an error
    def purge_id
      raw['purgeId']
    end

    # Message detailing the response
    # @return [String] message detailing the response. When the response represents an error
    #   this value can be one of the provided arguments
    def message
      raw['detail']
    end

    alias_method :detail, :message

    # Estimated time (in seconds) for the operation to be completed
    # @return [Fixnum] estimated time (in seconds) for the operation to be completed
    # @return [nil] when the response represents an error
    def estimated_time
      raw['estimatedSeconds']
    end

    # URI to use to ask the status. It can be used to ask the request status to AkamaiApi
    # @return [String] URI to use to ask the status
    # @return [nil] when the response represents an error
    def uri
      raw['progressUri']
    end

    alias_method :progress_uri, :uri
  end
end
