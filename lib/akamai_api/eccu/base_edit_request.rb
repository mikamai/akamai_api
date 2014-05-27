require "akamai_api/eccu/base_request"
require "akamai_api/eccu/not_found"

module AkamaiApi::Eccu
  # @abstract
  #
  # This class is intended as a generic superclass for all requests that operate on an existing
  # purge request submitted through the Akamai ECCU interface.
  class BaseEditRequest < BaseRequest
    # ECCU Request code
    # @return [String] request code
    attr_reader :code

    # @param code ECCU request code
    def initialize code
      @code = code.to_i
    end

    protected

    # Creates the request body filling it with all necessary arguments
    #
    # The base implementation fills only the request code. If the request needs additional
    # arguments you'll want to overwrite it like the following:
    #   class MyCustomRequest < AkamaiApi::Eccu::BaseEditRequest
    #     def request_body code, name, surname
    #       super code do |block|
    #         block.string(:name, name).string(:surname, surname)
    #       end
    #     end
    #   end
    def request_body *args, &block
      SoapBody.new.tap do |block|
        block.integer :fileId, code
        yield block if block_given?
      end
    end

    # Wrapper method that you can use inside your custom ECCU request to handle common errors
    # @raise [AkamaiApi::Unauthorized] when login credentials are invalid
    # @raise [AkamaiApi::Eccu::NotFound] when no request can be found with the given code
    def with_soap_error_handling &block
      super
    rescue Savon::SOAPFault => e
      e = ::AkamaiApi::Eccu::NotFound if e.to_hash[:fault][:faultstring] =~ /fileId .* does not exist/
      raise e
    end
  end
end
