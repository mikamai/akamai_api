module AkamaiApi::Ccu::PurgeStatus
  class Response < ::AkamaiApi::Ccu::Response
    def progress_uri
      raw['progressUri']
    end

    def purge_id
      raw['purgeId']
    end

    def status
      raw['purgeStatus']
    end

    def time_to_wait
      raw['pingAfterSeconds']
    end
  end
end
