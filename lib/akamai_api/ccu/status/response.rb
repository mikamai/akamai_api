require "akamai_api/ccu/base_response"

module AkamaiApi::CCU::Status
  # This response class describes the status of the Akamai CCU Queue
  class Response < AkamaiApi::CCU::BaseResponse
    # @return [Fixnum] Number of jobs in queue
    def queue_length
      raw['queueLength']
    end

    # @return [String] Message detailing the response
    def message
      raw['detail']
    end
    alias_method :detail, :message
  end
end
