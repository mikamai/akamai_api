require File.expand_path '../response', __FILE__

module AkamaiApi::Ccu::PurgeStatus
  class NotFoundResponse < Response
    def message
      raw['detail']
    end
  end
end
