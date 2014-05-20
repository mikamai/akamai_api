module AkamaiApi::Ccu::Status
  class Response < ::AkamaiApi::Ccu::Response
    def queue_length
      raw['queueLength']
    end

    def message
      raw['detail']
    end
  end
end
