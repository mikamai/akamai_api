module AkamaiApi::Ccu
  # @abstract
  # This class is intended as a generic superclass for all the specific responses that can be received
  # when doing a request through the Akamai CCU interface
  class Response
    # Raw JSON object used to build the response
    # @return [Hash]
    attr_reader :raw

    # @param [Hash] raw raw json object received from Akamai after the purge request
    def initialize raw
      @raw = raw
    end

    # @return [String] transaction ID assigned from Akamai to the request
    def support_id
      raw['supportId']
    end

    # Response HTTP Status Code
    # @return [Fixnum] returned HTTP Status Code
    def code
      raw['httpStatus']
    end

    alias :http_status :code

    # Indicates whether the request was successful or not
    # @return [true] when the request was successful
    # @return [false] when the request wasn't successful and the response is describing an error
    def successful?
      code == 200 || code == 201
    end
  end
end
