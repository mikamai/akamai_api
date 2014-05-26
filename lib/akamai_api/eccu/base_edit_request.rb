require "akamai_api/eccu/base_request"
require "akamai_api/eccu/not_found"

module AkamaiApi::Eccu
  class BaseEditRequest < BaseRequest
    attr_reader :code

    def initialize code
      @code = code.to_i
    end

    def request_body *args
      SoapBody.new.tap do |block|
        block.integer :fileId, code
        yield block if block_given?
      end
    end

    protected

    def with_soap_error_handling &block
      super
    rescue Savon::SOAPFault => e
      e = ::AkamaiApi::Eccu::NotFound if e.to_hash[:fault][:faultstring] =~ /fileId .* does not exist/
      raise e
    end
  end
end
