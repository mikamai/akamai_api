require "akamai_api/ccu/base_response"

module AkamaiApi::CCU::Purge
  # This class represents the response received after a successful purge request
  class Response < AkamaiApi::CCU::BaseResponse
    # @return [Fixnum] Suggested time to wait (in seconds) before asking the status again
    def time_to_wait
      5
    end
    alias_method :ping_after_seconds, :time_to_wait

    # Purge Request identifier
    # @return [String] Purge Request identifier
    def purge_id
      raw['purgeId']
    end

    # Message detailing the response
    # @return [String] message detailing the response.
    def message
      raw['detail']
    end
    alias_method :detail, :message

    # @return [Fixnum] Estimated time (in seconds) for the operation to be completed
    def estimated_time
      5
    end
    alias_method :estimated_seconds, :estimated_time
  end
end
