require "akamai_api/ccu/response"

module AkamaiApi::Ccu::Purge
  class Response < ::AkamaiApi::Ccu::Response
    def described_by
      raw['describedBy']
    end

    def title
      raw['title']
    end

    def time_to_wait
      raw['pingAfterSeconds']
    end

    def purge_id
      raw['purgeId']
    end

    def message
      raw['detail']
    end

    def estimated_time
      raw['estimatedSeconds']
    end

    def uri
      raw['progressUri']
    end
  end
end
