require "akamai_api/ccu/purge_status/response"

module AkamaiApi::Ccu::PurgeStatus
  # This response object is returned by {Request} when no purge request can be found with the
  # given id
  class NotFoundResponse < Response
    # Message detailing the response
    # @return [String] message detailing the response
    def message
      raw['detail']
    end

    alias_method :detail, :message
  end
end
