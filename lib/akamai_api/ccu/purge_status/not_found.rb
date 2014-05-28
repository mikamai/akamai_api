require "akamai_api/ccu/error"

module AkamaiApi::CCU::PurgeStatus
  # {NotFound} is raised when the requested resource cannot be found
  class NotFound < AkamaiApi::CCU::Error
    # @return [String] URI to use to check the status of the request
    def progress_uri
      raw['progressUri']
    end
    alias_method :uri, :progress_uri

    # @return [Fixnum] Suggested time to wait (in seconds) before asking the status again
    def time_to_wait
      raw['pingAfterSeconds']
    end
    alias_method :ping_after_seconds, :time_to_wait
  end
end
