require "akamai_api/ccu/error"

module AkamaiApi::CCU::PurgeStatus
  class NotFound < AkamaiApi::CCU::Error
    def progress_uri
      raw['progressUri']
    end
    alias_method :uri, :progress_uri

    def time_to_wait
      raw['pingAfterSeconds']
    end
    alias_method :ping_after_seconds, :time_to_wait
  end
end
