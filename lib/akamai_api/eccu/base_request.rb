require "savon"

require "akamai_api/unauthorized"
require "akamai_api/eccu/not_found"

module AkamaiApi::Eccu
  class BaseRequest
    attr_reader :code

    def initialize code
      @code = code
    end

    protected

    def with_soap_error_handling &block
      yield
    rescue Savon::HTTPError => e
      e = ::AkamaiApi::Unauthorized if e.http.code == 401
      raise e
    rescue Savon::SOAPFault => e
      e = ::AkamaiApi::Eccu::NotFound if e.to_hash[:fault][:faultstring] =~ /fileId .* does not exist/
      raise e
    end

    def client_call method, *args
      client.call method, *args
    end

    def client
      AkamaiApi::Eccu.client
    end
  end
end
