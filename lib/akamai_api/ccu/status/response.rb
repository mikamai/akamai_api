require "akamai_api/ccu/response"

module AkamaiApi::Ccu::Status
  # This response class describes the status of the Akamai CCU Queue
  class Response < ::AkamaiApi::Ccu::Response
    # Number of jobs in queue
    # @return [Fixnum] number of jobs in queue
    def queue_length
      raw['queueLength']
    end

    # Message detailing the response
    # @return [String] message detailing the response
    def message
      raw['detail']
    end

    alias_method :detail, :message
  end
end
