require "akamai_api/error"

module AkamaiApi::CCU
  # Error received after a request done through the Akamai CCU interface.
  class Error < AkamaiApi::Error
    # @return [Hash<String, Object>] raw Raw object describing the error.
    attr_reader :raw

    # @param [Hash<String, Object>] raw Raw object describing the error.
    def initialize raw
      @raw = raw
      super raw['title'] || raw['detail']
    end

    # @return [String] Reference provided to Customer Care when needed.
    def support_id
      raw['supportId']
    end

    # @return [String] Specific detail about the error
    def detail
      raw['detail']
    end

    alias_method :title, :message

    # @return [Fixnum] Response HTTP Status Code describing the error
    def code
      raw['httpStatus']
    end
    alias_method :http_status, :code

    # @return [String] URI pointing to a verbose error description
    def described_by
      raw['describedBy']
    end
  end
end
