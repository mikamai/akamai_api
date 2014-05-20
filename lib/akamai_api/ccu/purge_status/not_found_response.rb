require File.expand_path '../response', __FILE__

module AkamaiApi::Ccu::PurgeStatus
  class NotFoundResponse < Response
    def message
      raw_body['detail']
    end
  end
end
