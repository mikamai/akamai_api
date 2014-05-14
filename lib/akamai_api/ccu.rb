require 'httparty'
require 'active_support/core_ext'

module AkamaiApi
  module Ccu
    extend self

    class UnrecognizedOption < StandardError; end
    class Unauthorized < StandardError; end

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

      auth = { username: AkamaiApi.config[:auth].first, password: AkamaiApi.config[:auth].last }
      query = { type: type, action: action, objects: Array.wrap(items) }
      if args.key?(:domain)
        domain = args.delete(:domain)
        query[:domain] = domain if domain
      end
      response = HTTParty.post 'https://api.ccu.akamai.com/ccu/v2/queues/default', {
        basic_auth: auth,
        body: query.to_json,
        headers: { 'Content-Type' => 'application/json' }
      }
      raise Unauthorized if response.code == 401
      CcuResponse.new JSON.parse(response.body), items
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

    def client
      savon_args = {
        :wsdl => File.expand_path('../../../wsdls/ccuapi.wsdl', __FILE__),
        :namespaces => {
          'xmlns:soapenc' => 'http://schemas.xmlsoap.org/soap/encoding/'
        },
        :log => AkamaiApi.config[:log]
      }
      Savon.client savon_args
    end
  end
end
