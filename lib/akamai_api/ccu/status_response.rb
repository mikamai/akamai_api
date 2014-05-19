module AkamaiApi::Ccu
  class StatusResponse
    attr_reader :raw

    def initialize raw
      @raw = raw
    end

    def code
      raw['httpStatus']
    end

    def queue_length
      raw['queueLength']
    end

    def message
      raw['detail']
    end

    def support_id
      raw['supportId']
    end
  end
end
