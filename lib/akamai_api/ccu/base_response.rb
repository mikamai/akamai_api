module AkamaiApi
  module CCU
    # @abstract
    # This class is intended as a generic superclass for all the specific responses that can be received
    # when doing a request through the Akamai CCU interface
    class BaseResponse
      # @return [Hash<String, *>] raw Raw object describing the error.
      attr_reader :raw

      # @param [Hash<String, *>] raw Raw object describing the error.
      def initialize raw
        @raw = raw
      end

      # @return [String] Reference provided to Customer Care when needed.
      def support_id
        raw['supportId']
      end

      # @return [Fixnum] Response HTTP Status Code describing the error
      def code
        raw['httpStatus']
      end
      alias :http_status :code
    end
  end
end
