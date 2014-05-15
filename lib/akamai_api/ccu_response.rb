require 'ostruct'
require 'active_support/core_ext/module/delegation'

module AkamaiApi
  class CcuResponse
    attr_reader :raw_body, :requested_items

    def initialize(body, requested_items)
      @raw_body = body
      @requested_items = requested_items
    end

    def body
      @body ||= OpenStruct.new(raw_body[:purge_request_response][:return])
    end

    def described_by
      raw_body['describedBy']
    end

    def title
      raw_body['title']
    end

    def time_to_wait
      raw_body['pingAfterSeconds']
    end

    def purge_id
      raw_body['purgeId']
    end

    def support_id
      raw_body['supportId']
    end

    def message
      raw_body['detail']
    end

    def code
      raw_body['httpStatus']
    end

    def estimated_time
      raw_body['estimatedSeconds']
    end

    def uri
      raw_body['progressUri']
    end
  end
end
