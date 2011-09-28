require 'mustache'

module AkamaiApi
  class Ccu
    include AkamaiApi::WebService

    use_manifest 'https://ccuapi.akamai.com/ccuapi-axis.wsdl', 'ccuapi-axis.wsdl'

    service_call :purge do |uris, options|
      options ||= {}
      req = client.request('purgeRequest') do |soap|
        view = PurgeRequest.new
        view.username = account.username rescue ''
        view.password = account.password rescue ''
        view.options = options.map { |k, v| { :key => k, :value => v } }
        view.uris = uris
        soap.xml = view.render
      end

      resp = req.to_hash[:purge_request_response][:return]
      code = resp[:result_code].to_i
      if code == 301
        raise LoginError.new
      else
        uri_index = resp[:uri_index].to_i
        {
          :code => code,
          :message => resp[:result_msg],
          :id => resp[:session_id],
          :time => resp[:est_time].to_i,
          :failed_uri => uri_index > 0 && uris[uri_index] || nil
        }
      end
    end

    private
    class PurgeRequest < ::Mustache
      attr_accessor :username, :password, :options, :uris

      self.template_path = File.join File.dirname(__FILE__), '../../templates'
    end
  end
end
