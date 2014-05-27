require "akamai_api/unauthorized"

module AkamaiApi::Eccu
  # @abstract
  #
  # This class is intended as a generic superclass for all the specific requests that can be used
  # with the Akamai ECCU interface
  class BaseRequest
    protected

    # Wrapper method that you can use inside your custom ECCU request to handle common errors
    # @raise [AkamaiApi::Unauthorized] when login credentials are invalid
    def with_soap_error_handling &block
      yield
    rescue Savon::HTTPError => e
      e = ::AkamaiApi::Unauthorized if e.http.code == 401
      raise e
    end

    # Executes a method via Savon and returns the response
    # @param [String] method method name to call
    # @param args additional arguments to pass to savon when calling the method
    # @return [Object] the object containing the received response
    def client_call method, *args
      client.call(method, *args).body["#{method}_response".to_sym]
    end

    def client
      AkamaiApi::Eccu.client
    end
  end
end
