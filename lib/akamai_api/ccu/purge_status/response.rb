module AkamaiApi::Ccu::PurgeStatus
  class Response
    attr_reader :raw_body

    def initialize(body)
      @raw_body = body
    end

    def progress_uri
      raw_body['progressUri']
    end

    def purge_id
      raw_body['purgeId']
    end

    def support_id
      raw_body['supportId']
    end

    def code
      raw_body['httpStatus']
    end

    def status
      raw_body['purgeStatus']
    end

    def time_to_wait
      raw_body['pingAfterSeconds']
    end
  end
end
