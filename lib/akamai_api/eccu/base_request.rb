require "savon"

require "akamai_api/unauthorized"

module AkamaiApi::Eccu
  class BaseRequest
    protected

    def with_soap_error_handling &block
      yield
    rescue Savon::HTTPError => e
      e = ::AkamaiApi::Unauthorized if e.http.code == 401
      raise e
    end

    def client_call method, *args
      client.call(method, *args).body["#{method}_response".to_sym]
    end

    def client
      AkamaiApi::Eccu.client
    end
  end
end
