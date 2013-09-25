require 'active_support/core_ext'

module AkamaiApi
  module Ccu
    extend self

    class UnrecognizedOption < StandardError; end

    [:invalidate, :remove].each do |action|
      send :define_method, action do |*params|
        raise ArgumentError, "wrong number of arguments (#{params.length} for 2..3)" if params.length < 2
        type, items, opts = params
        purge action, type, items, (opts || {})
      end
      [:arl, :cpcode].each do |type|
        method_name = "#{action}_#{type}".to_sym
        send :define_method, method_name do |*params|
          raise ArgumentError, "wrong number of arguments (#{params.length} for 1..2)" if params.length < 1
          items, opts = params
          purge action, type, items, (opts || {})
        end
      end
    end

    def purge action, type, items, args = {}
      validate_action action
      validate_type type
      options = ["action=#{action}", "type=#{type}"]
      add_domain args[:domain], options
      add_email args[:email], options
      body = SoapBody.new do
        string :name,    AkamaiApi.config[:auth].first
        string :pwd,     AkamaiApi.config[:auth].last
        string :network, ''
        array  :opt,     options
        array  :uri,     Array.wrap(items)
      end
      response = client.call :purge_request, :message => body.to_s
      CcuResponse.new response, items
    end

    private

    def validate_action action
      unless %w[invalidate remove].include? action.to_s
        raise UnrecognizedOption, "Unknown type '#{action}' (only 'remove' and 'invalidate' are allowed)"
      end
    end

    def validate_type type
      unless %w[cpcode arl].include? type.to_s
        raise UnrecognizedOption, "Unknown type '#{type}' (only 'cpcode' and 'arl' are allowed)"
      end
    end

    def add_domain domain, options
      if domain.present?
        unless %w[production staging].include? domain.to_s
          raise "Unknown domain type '#{domain}' (only :production and :staging are allowed)"
        end
        options << "domain=#{domain}"
      end
    end

    def add_email email, options
      if email.present?
        emails = Array.wrap(email).join ','
        options << "email-notification=#{emails}"
      end
    end

    def client
      savon_args = {
        :wsdl => File.expand_path('../../../wsdls/ccuapi.wsdl', __FILE__),
        :namespaces => {
          'xmlns:soapenc' => 'http://schemas.xmlsoap.org/soap/encoding/'
        }
      }
      Savon.client savon_args
    end
  end
end
