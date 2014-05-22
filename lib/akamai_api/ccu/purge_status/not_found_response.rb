require "akamai_api/ccu/purge_status/response"

module AkamaiApi::Ccu::PurgeStatus
  class NotFoundResponse < Response
    def message
      raw['detail']
    end
  end
end
